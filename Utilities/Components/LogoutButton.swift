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
    @State private var currentLanguage = LanguageHelper.shared.currentLanguage
    var body: some View {
        Button {
            signOut()
        } label: {
            Text("log_out".localized())
                .font(.montserrat(.bold, size: 17))
                .foregroundColor(.black)
                .underline()
                .padding(15)
                .onChange(of: LanguageHelper.shared.currentLanguage) { newValue in
                    currentLanguage = newValue
                }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            AuthenticationManager.shared.logOut()
            ProfileManager.shared.clearAll()
            print("User signed out successfully!")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
