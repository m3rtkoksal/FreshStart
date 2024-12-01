//
//  DeleteAccountButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Firebase
import FirebaseAuth

struct DeleteAccountButton: View {
    @State private var showDeleteAlert = false
    
    var body: some View {
        Button(action: {
            showDeleteAlert = true
        }) {
            Text("Delete Account")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black) // Set text color to gray
                .padding(15)
                .background(Color.mkOrange) 
                .cornerRadius(38) // Rounded corners
                .overlay(
                    RoundedRectangle(cornerRadius: 38)
                        .strokeBorder(Color.black, lineWidth: 2) // Border color
                        .shadow(color: Color(red: 0.51, green: 0.74, blue: 0.62, opacity: 0.3), radius: 20, x: 0, y: 0) // Shadow effect
                )
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Confirm Account Deletion"),
                message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                primaryButton: .destructive(Text("Yes, Delete")) {
                    deleteUserAccount() // Call delete function if user confirms
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func deleteUserAccount() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let userId = user.uid
        let db = Firestore.firestore()
        
        // 1. Delete all dietPlans for the user
        db.collection("dietPlans").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching diet plans: \(error.localizedDescription)")
            } else {
                let batch = db.batch()
                for document in querySnapshot?.documents ?? [] {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error deleting diet plans: \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted diet plans.")
                    }
                }
            }
        }
        
        // 2. Delete all healthData entries for the user
        db.collection("healthData").whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching health data: \(error.localizedDescription)")
            } else {
                let batch = db.batch()
                for document in querySnapshot?.documents ?? [] {
                    batch.deleteDocument(document.reference)
                }
                batch.commit { error in
                    if let error = error {
                        print("Error deleting health data: \(error.localizedDescription)")
                    } else {
                        print("Successfully deleted health data.")
                    }
                }
            }
        }
        
        // 3. Delete the user's main document in the "users" collection
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user document: \(error.localizedDescription)")
            } else {
                print("User document deleted successfully.")
                
                // 4. Delete the user from Firebase Authentication
                user.delete { error in
                    if let error = error {
                        print("Error deleting user account: \(error.localizedDescription)")
                    } else {
                        do {
                            try Auth.auth().signOut()
                            AuthenticationManager.shared.logOut()
                            print("User account deleted and signed out successfully.")
                        } catch let signOutError as NSError {
                            print("Error signing out: %@", signOutError)
                        }
                    }
                }
            }
        }
    }
}


#Preview {
    DeleteAccountButton()
}
