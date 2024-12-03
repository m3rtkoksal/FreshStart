//
//  LoginVM.swift
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

class LoginVM: BaseViewModel, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding  {
    
    @Published var errorMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var goToHealthPermission = false
    @Published var goToRegisterView = false
    @Published var goToPasswordReset = false
    @Published var goToRegister = false
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow }!
    }
    
    func signInWithApple() {
        self.showIndicator = true
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        let fullName = appleIDCredential.fullName

        // Convert identityToken from Data to String
        guard let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8) else {
            return
        }
        
        let credential = OAuthProvider.credential(providerID: .apple,
                                                  idToken: idTokenString,
                                                  rawNonce: "")

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                AnalyticsHelper.log("Firebase sign-in failed",
                                    eventParameters: ["error" : error.localizedDescription])
                self.errorMessage = error.localizedDescription
                self.showAlert = true
                return
            }

            // User is signed in
            if let user = authResult?.user {
                AnalyticsHelper.log("User signed in",
                                    eventParameters: ["userId" : user.uid])
                self.saveAppleUserToFirestore(userIdentifier: user.uid, fullName: fullName, email: user.email)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AnalyticsHelper.log("Apple Sign-In failed",
                            eventParameters: ["error" : error.localizedDescription])
        self.errorMessage = error.localizedDescription
        self.showAlert = true
    }

    func saveAppleUserToFirestore(userIdentifier: String, fullName: PersonNameComponents?, email: String? ) {
        let db = Firestore.firestore()

        db.collection("users").document(userIdentifier).getDocument { (document, error) in
            if let error = error {
                AnalyticsHelper.log("Error checking if user exists",
                                    eventParameters: ["error" : error.localizedDescription])
                return
            }

            if document?.exists == true {
                // If the user exists, update their data
                db.collection("users").document(userIdentifier).updateData([
                    "name": fullName?.givenName ?? "",
                    "surname": fullName?.familyName ?? "",
                    "email": email ?? ""
                ]) { error in
                    if let error = error {
                        AnalyticsHelper.log("Error updating Apple Sign-In data",
                                            eventParameters: ["error" : error.localizedDescription])
                    } else {
                        self.showIndicator = false
                        AnalyticsHelper.log("user_signin_apple",
                                            eventParameters: ["name": fullName?.givenName ?? "",
                                                              "surname": fullName?.familyName ?? "",
                                                              "email": email ?? "",
                                                              "date": Date().getFormattedDate(format: "dd.MM.yyyy HH:mm")])
                        AuthenticationManager.shared.logIn()
                    }
                }
            } else {
                db.collection("users").document(userIdentifier).setData([
                    "userId": userIdentifier,
                    "name": fullName?.givenName ?? "",
                    "surname": fullName?.familyName ?? "",
                    "email": email ?? ""
                ]) { error in
                    if let error = error {
                        AnalyticsHelper.log("Error updating Apple Sign-In data",
                                            eventParameters: ["error" : error.localizedDescription])
                    } else {
                        self.showIndicator = false
                        AnalyticsHelper.log("user_signup_apple",
                                            eventParameters: ["name": fullName?.givenName ?? "",
                                                              "surname": fullName?.familyName ?? "",
                                                              "email": email ?? "",
                                                              "date": Date().getFormattedDate(format: "dd.MM.yyyy HH:mm")])
                        self.goToHealthPermission = true
                    }
                }
            }
        }
    }
    
    func signUpWithGoogle() {
        self.showIndicator = true
        guard let presentingVC = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let rootViewController = presentingVC.keyWindow?.rootViewController else {
            self.showIndicator = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            if error != nil {
                self?.showIndicator = false
                return
            }
            
            guard let googleUser = signInResult?.user else {
                self?.showIndicator = false
                return
            }

            guard let idToken = googleUser.idToken else {
                self?.showIndicator = false
                return
            }
            
            let name = googleUser.profile?.givenName
            let surname = googleUser.profile?.familyName
            let email = googleUser.profile?.email

            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: googleUser.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil {
                    self?.showIndicator = false
                    return
                }
                if let firebaseUser = authResult?.user {
                    self?.saveGoogleUserToFirestore(userIdentifier: firebaseUser.uid, name: name,surname: surname, email: email) {
                        self?.showIndicator = false
                    }
                } else {
                    self?.showIndicator = false
                }
            }
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            AuthenticationManager.shared.logOut()
        } catch {
            print(error)
        }
    }

    
    func saveGoogleUserToFirestore(userIdentifier: String, name: String?,surname: String?, email: String?, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userIdentifier).getDocument { (document, error) in
            if let error = error {
                print("Error checking if user exists: \(error.localizedDescription)")
                return
            }

            if document?.exists == true {
                print("User already exists, updating data.")
                db.collection("users").document(userIdentifier).updateData([
                    "name": name ?? "",
                    "surname": surname ?? "",
                    "email": email ?? ""
                ]) { error in
                    if error != nil {
                    } else {
                        AuthenticationManager.shared.isLoggedIn = true
                        completion()
                    }
                }
            } else {
                // Create a new document if user does not exist
                db.collection("users").document(userIdentifier).setData([
                    "userId": userIdentifier,
                    "name": name ?? "",
                    "surname": surname ?? "",
                    "email": email ?? "",
                    "maxPlanCount": 1,
                    "maxMealCount": 1
                ]) { error in
                    if error != nil {
                    } else {
                        self.goToHealthPermission = true
                        completion()
                    }
                }
            }
        }
    }

}
