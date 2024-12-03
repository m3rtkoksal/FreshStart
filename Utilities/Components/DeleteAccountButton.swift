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
    
    var body: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            Text("Delete Account")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
                .padding(15)
                .background(Color.mkOrange)
                .cornerRadius(38)
                .overlay(
                    RoundedRectangle(cornerRadius: 38)
                        .strokeBorder(Color.black, lineWidth: 2)
                        .shadow(color: Color(red: 0.51, green: 0.74, blue: 0.62, opacity: 0.3), radius: 20, x: 0, y: 0) // Shadow effect
                )
        }
        .onChange(of: deleteConfirmation) { newValue in
            if newValue {
                deleteUserAccount()
            }
        }
    }
    
    func deleteUserAccount() {
        // Get the current user
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        
        // First, sign out from Firebase
        do {
            // Sign out from Firebase
            try Auth.auth().signOut()

            // Check if the user is signed in with Google
            if let googleUser = GIDSignIn.sharedInstance.currentUser {
                // Sign out from Google
                GIDSignIn.sharedInstance.signOut()
                print("User signed out from Google.")
            }
            
            // Check if the user is signed in with Apple
            if let appleUser = user.providerData.first(where: { $0.providerID == "apple.com" }) {
                // Sign out from Apple
                let provider = OAuthProvider(providerID: "apple.com")
                provider.getCredentialWith(nil) { credential, error in
                    if let error = error {
                        print("Error signing out from Apple: \(error.localizedDescription)")
                        return
                    }
                    Auth.auth().currentUser?.link(with: credential!) { _, error in
                        if let error = error {
                            print("Apple sign-out error: \(error.localizedDescription)")
                        } else {
                            print("User signed out from Apple.")
                        }
                    }
                }
            }

            // Delete user data from Firestore
            deleteUserDataFromFirestore(userIdentifier: user.uid)

        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    // Function to delete the user data from Firestore
    func deleteUserDataFromFirestore(userIdentifier: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userIdentifier).delete { error in
            if let error = error {
                print("Error deleting user data from Firestore: \(error.localizedDescription)")
            } else {
                print("User data deleted successfully from Firestore.")
            }
        }
    }

}
