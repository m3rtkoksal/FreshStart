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
                    title: "password_reset.forgot_password_title".localized(),
                    subtitle: "password_reset.forgot_password_subtitle".localized(),
                    color: .white
                )
                ValidatingTextField(
                    text: $validationModel.email,
                    validator: validationModel.emailValidator,
                    placeholder: "password_reset.email_placeholder".localized()
                )
                FreshStartButton(text: "password_reset.reset_password_button".localized(), backgroundColor: .mkOrange) {
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
            .fsAlertModifier(
                isPresented: $showAlert,
                title: "password_reset.password_reset_alert_title".localized(),
                message: errorMessage,
                confirmButtonText: "password_reset.ok_button".localized(),
                confirmAction: {
                    withAnimation {
                        showAlert = false
                    }
                }
            )
        }
    }
    func sendPasswordReset() {
        Auth.auth().sendPasswordReset(withEmail: validationModel.email) { error in
            if let error = error {
                self.errorMessage = "password_reset.error_message".localized() + ": \(error.localizedDescription)"
            } else {
                self.errorMessage = "password_reset.password_reset_email_sent".localized()
            }
        }
    }
}

#Preview {
    PasswordResetView()
}
