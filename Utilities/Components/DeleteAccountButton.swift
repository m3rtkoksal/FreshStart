//
//  DeleteAccountButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn

struct DeleteAccountButton: View {
    @Binding var showDeleteAlert: Bool
    @Binding var deleteConfirmation: Bool
    @State private var currentLanguage = LanguageHelper.shared.currentLanguage
    
    var body: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            Text("delete_account".localized())
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .padding(15)
                .background(Color.mkOrange)
                .cornerRadius(38)
                .onChange(of: LanguageHelper.shared.currentLanguage) { newValue in
                    currentLanguage = newValue
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 38)
                        .strokeBorder(Color.black, lineWidth: 2)
                        .shadow(color: Color(red: 0.51, green: 0.74, blue: 0.62, opacity: 0.3), radius: 20, x: 0, y: 0)
                )
        }
        .onChange(of: deleteConfirmation) { newValue in
            if newValue {
                deleteUserAccount()
            }
        }
    }
    
    func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        let userId = user.uid
        let db = Firestore.firestore()
        
        // Delete health data
        let healthDataRef = db.collection("healthData").whereField("userId", isEqualTo: userId)
        healthDataRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching health data: \(error.localizedDescription)")
            } else {
                for document in querySnapshot?.documents ?? [] {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting health data document: \(error.localizedDescription)")
                        } else {
                            print("Health data document deleted successfully.")
                        }
                    }
                }
            }
        }
        
        // Delete diet plans
        let dietPlansRef = db.collection("dietPlans").whereField("userId", isEqualTo: userId)
        dietPlansRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching diet plans: \(error.localizedDescription)")
            } else {
                for document in querySnapshot?.documents ?? [] {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting diet plan document: \(error.localizedDescription)")
                        } else {
                            print("Diet plan document deleted successfully.")
                        }
                    }
                }
            }
        }
        
        // Delete user document
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user document: \(error.localizedDescription)")
            } else {
                print("User document deleted successfully.")
            }
        }
        
        // Perform sign-out
        signOutUser()
    }
    
    func signOutUser() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            AuthenticationManager.shared.logOut()
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
}
