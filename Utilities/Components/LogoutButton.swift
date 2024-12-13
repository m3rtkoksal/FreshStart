//
//  LogoutButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct LogoutButton: View {
    var body: some View {
        Button {
            signOut()
        } label: {
            Text("log_out".localized())
                .font(.montserrat(.bold, size: 17))
                .foregroundColor(.black)
                .underline()
                .padding(15)
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            AuthenticationManager.shared.logOut()
            print("User signed out successfully!")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
