//
//  RegisterVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//


import Foundation
import AuthenticationServices
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

class RegisterVM: BaseViewModel, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    @Published var goToBMIInputPage = false
    @Published var menuPickerItems: [FSDropdownItemModel] = []
    @Published var goToHealthPermission = false
    @Published var goToLogin = false
    @Published var goToPrivacyPolicy = false
    
    func fetchMenuItems() {
        self.menuPickerItems = [
            FSDropdownItemModel(id: "0", icon: "male", text: "Male", hasArrow: false),
            FSDropdownItemModel(id: "1", icon: "female", text: "Female", hasArrow: false)
        ]
    }
    func signUpWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    // MARK: - ASAuthorizationControllerDelegate Methods
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.showIndicator = false
            return
        }
        
        let fullName = appleIDCredential.fullName
        guard let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            self.showIndicator = false
            return
        }
        print("Apple Sign-In Successful. Full Name: \(String(describing: fullName))")
        
        let credential = OAuthProvider.credential(providerID: .apple, idToken: idTokenString, rawNonce: "")
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                AnalyticsHelper.log("Firebase sign-in failed",
                                    eventParameters: ["error" : error.localizedDescription])
                return
            }
            if let user = authResult?.user {
                AnalyticsHelper.log("User signed in",
                                    eventParameters: ["userId" : user.uid])
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        AnalyticsHelper.log("User already exists in Firestore.",
                                            eventParameters: ["userId" : user.uid])
                        AuthenticationManager.shared.isLoggedIn = true
                    } else {
                        self.saveAppleUserToFirestore(userIdentifier: user.uid, fullName: fullName, email: user.email) {
                            self.goToHealthPermission = true
                        }
                    }
                    self.showIndicator = false
                }
            }
        }
    }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.showIndicator = false
        AnalyticsHelper.log("Apple Sign-In failed",
                            eventParameters: ["error" : error.localizedDescription])
    }
    
    func saveAppleUserToFirestore(userIdentifier: String, fullName: PersonNameComponents?, email: String?, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userIdentifier).getDocument { (document, error) in
            if let error = error {
                AnalyticsHelper.log("Error checking if user exists",
                                    eventParameters: ["error" : error.localizedDescription])
                return
            }

            if document?.exists == true {
                AnalyticsHelper.log("User already exists in Firestore.",
                                    eventParameters: [:])
                db.collection("users").document(userIdentifier).updateData([
                    "name": fullName?.givenName ?? "",
                    "surname": fullName?.familyName ?? "",
                    "email": email ?? ""
                ]) { error in
                    if let error = error {
                        AnalyticsHelper.log("Error updating Apple Sign-In data",
                                            eventParameters: ["error" : error.localizedDescription])
                    } else {
                        AnalyticsHelper.log("Apple Sign-In data updated successfully!",
                                            eventParameters: [:])
                        AuthenticationManager.shared.isLoggedIn = true
                        self.showIndicator = false
                        completion()
                    }
                }
            } else {
                db.collection("users").document(userIdentifier).setData([
                    "userId": userIdentifier,
                    "name": fullName?.givenName ?? "",
                    "surname": fullName?.familyName ?? "",
                    "email": email ?? "",
                    "maxPlanCount": 1,
                    "maxMealCount": 4,
                    "dailyLoginCount" : 1
                ]) { error in
                    if let error = error {
                        AnalyticsHelper.log("Error saving Apple Sign-In data",
                                            eventParameters: ["error" : error.localizedDescription])
                    } else {
                        AnalyticsHelper.log("Apple Sign-In data saved successfully!",
                                            eventParameters: [:])
                        AuthenticationManager.shared.isLoggedIn = true
                        self.showIndicator = false
                        completion()
                    }
                }
            }
        }
    }

    func signUpWithGoogle() {
        self.showIndicator = true
        guard let presentingVC = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let rootViewController = presentingVC.keyWindow?.rootViewController else {
            return
        }
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            if let error = error {
                AnalyticsHelper.log("Error during Google Sign-In",
                                    eventParameters: ["error" : error.localizedDescription])
                return
            }
            guard let googleUser = signInResult?.user else {
                return
            }
            guard let idToken = googleUser.idToken else {
                return
            }
            let name = googleUser.profile?.givenName
            let surname = googleUser.profile?.familyName
            let email = googleUser.profile?.email
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: googleUser.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    AnalyticsHelper.log("Firebase sign-in failed",
                                        eventParameters: ["error" : error.localizedDescription])
                    return
                }
                if let firebaseUser = authResult?.user {
                    AnalyticsHelper.log("User signed in",
                                        eventParameters: ["userId" : firebaseUser.uid])
                    AuthenticationManager.shared.isLoggedIn = true
                    self?.saveGoogleUserToFirestore(userIdentifier: firebaseUser.uid, name: name,surname: surname, email: email) {
                        self?.showIndicator = true
                    }
                }
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            AnalyticsHelper.log("Successfully signed out from Firebase and Google.",
                                eventParameters: [:])
            AuthenticationManager.shared.logOut()
        } catch let signOutError as NSError {
            AnalyticsHelper.log("Error signing out from Firebase",
                                eventParameters: ["error" : signOutError.localizedDescription])
        }
    }

    
    func saveGoogleUserToFirestore(userIdentifier: String, name: String?,surname: String?, email: String?, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userIdentifier).getDocument { (document, error) in
            if let error = error {
                AnalyticsHelper.log("Error checking if user exists",
                                    eventParameters: ["error" : error.localizedDescription])
                return
            }

            if document?.exists == true {
                print("User already exists, updating data.")
                AnalyticsHelper.log("User already exists, updating data.",
                                    eventParameters: [:])
                db.collection("users").document(userIdentifier).updateData([
                    "name": name ?? "",
                    "surname": surname ?? "",
                    "email": email ?? ""
                ]) { error in
                    if let error = error {
                        AnalyticsHelper.log("Error updating Google Sign-In data",
                                            eventParameters: ["error" : error.localizedDescription])
                    } else {
                        AnalyticsHelper.log("Google Sign-In data updated successfully!",
                                            eventParameters: [:])
                        self.showIndicator = false
                        AuthenticationManager.shared.isLoggedIn = true
                        AnalyticsHelper.log("user_signup_google",
                                            eventParameters: ["name": name ?? "",
                                                              "surname": surname ?? "",
                                                              "email": email ?? "",
                                                              "date": Date().getFormattedDate(format: "dd.MM.yyyy HH:mm")])
                        completion()
                    }
                }
            } else {
                db.collection("users").document(userIdentifier).setData([
                    "userId": userIdentifier,
                    "name": name ?? "",
                    "surname": surname ?? "",
                    "email": email ?? "",
                    "maxPlanCount": 1,
                    "maxMealCount": 4,
                    "dailyLoginCount": 1
                ]) { error in
                    if let error = error {
                        AnalyticsHelper.log("Error updating Google Sign-In data",
                                            eventParameters: ["error" : error.localizedDescription])
                    } else {
                        AnalyticsHelper.log("Google Sign-In data updated successfully!",
                                            eventParameters: [:])
                        self.showIndicator = false
                        AnalyticsHelper.log("user_signin_google",
                                            eventParameters: ["name": name ?? "",
                                                              "surname": surname ?? "",
                                                              "email": email ?? "",
                                                              "date": Date().getFormattedDate(format: "dd.MM.yyyy HH:mm")])
                        AuthenticationManager.shared.isLoggedIn = true
                        self.goToHealthPermission = true
                        completion()
                    }
                }
            }
        }
    }
}
