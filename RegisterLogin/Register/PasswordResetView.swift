//
//  PasswordResetView.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//


import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BaseViewModel()
    @StateObject private var validationModel = ValidationModel()
    @State private var errorMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .black,
               showIndicator: $viewModel.showIndicator) {
            VStack{
                FSTitle(
                    title: "Forgot Password",
                    subtitle: "Please enter your email address to recieve your password reset code",
                    color: .white)
                
                ValidatingTextField(
                    text: $validationModel.email,
                    validator: validationModel.emailValidator,
                    placeholder: "Email Address"
                )
                
                FreshStartButton(text: "Reset Password", backgroundColor: .mkOrange) {
                    sendPasswordReset()
                    self.showAlert = true
                }
                .padding(.top,30)
                Spacer()
                ZStack {
                    Image("walkthrough1ImageSet")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(edges: .bottom)
                }
                .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading:
                    FreshStartBackButton(color: .white)
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK")) {
                        showAlert = false
                        self.dismiss()
                    }
                )
            }
        }
    }
    func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: validationModel.email) { error in
            if let error = error {
                self.errorMessage = "Error: \(error.localizedDescription)"
            } else {
                self.errorMessage = "Password reset email sent. Please check your inbox."
            }
        }
    }
}

#Preview {
    PasswordResetView()
}
