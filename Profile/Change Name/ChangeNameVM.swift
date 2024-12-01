//
//  ChangeNameVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class ChangeNameVM: BaseViewModel {
    @Published var errorMessage: String?
    
    func updateFirstName(newFirstName: String) {
        updateUserField(field: "name", newValue: newFirstName) {
            ProfileManager.shared.setUserFirstName(newFirstName)
        }
    }
    
    func updateSurname(newSurname: String) {
        updateUserField(field: "surname", newValue: newSurname) {
            ProfileManager.shared.setUserSurname(newSurname)
        }
    }
    
    func updateUsername(newUsername: String) {
        updateUserField(field: "username", newValue: newUsername) {
            ProfileManager.shared.setUserName(newUsername)
        }
    }
    
    private func updateUserField(field: String, newValue: String, onSuccess: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "No user is currently logged in."
            return
        }
        self.showIndicator = true
        
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([field: newValue]) { error in
            DispatchQueue.main.async {
                self.showIndicator = false
                if let error = error {
                    self.errorMessage = "Error updating \(field): \(error.localizedDescription)"
                } else {
                    onSuccess()
                    self.errorMessage = "\(field.capitalized) updated successfully!"
                }
            }
        }
    }
}

