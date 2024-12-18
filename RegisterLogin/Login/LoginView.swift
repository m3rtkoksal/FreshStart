//
//  LoginView.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//


import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @StateObject private var validationModel = ValidationModel()
    @StateObject private var viewModel = LoginVM()
    @State private var errorMessage = ""
    @State private var showAlert = false
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack {
                        FSTitle(
                            title: "login.welcome_title".localized(),
                            subtitle: "login.welcome_subtitle".localized())
                        
                        ValidatingTextField(text: $validationModel.email,
                                            validator: validationModel.emailValidator,
                                            placeholder: "login.email_address".localized())
                        
                        SecureValidatingTextField(text: $validationModel.password,
                                                  validator: validationModel.passwordValidator,
                                                  placeholder: "login.password".localized())
                        .padding(.top, 20)
                        HStack {
                            Spacer()
                            Button("login.forgot_password".localized()) {
                                viewModel.goToPasswordReset = true
                            }
                            .font(.montserrat(.semiBold, size: 14))
                            .foregroundColor(.black)
                            .padding(.trailing, 20)
                        }
                        .padding(.top,10)
                        FreshStartButton(text: "login.login_button".localized(), backgroundColor: .mkOrange, textColor: .black) {
                            signIn()
                        }
                        .padding(.top, 20)
                        Spacer(minLength: geometry.size.height * 0.2)
                        VStack(spacing: 50){
                            FreshStartDivider(title: "login.or_login_with".localized())
                            VStack(spacing:10) {
                                FreshStartButton(
                                    image: "google-icon",
                                    text: "login.connect_with_google".localized(),
                                    backgroundColor: .white) {
                                        viewModel.signUpWithGoogle()
                                    }
                                FreshStartButton(
                                    image: "apple_icon",
                                    text: "login.connect_with_apple".localized(),
                                    backgroundColor: .mkPurple,
                                    textColor: .white) {
                                        viewModel.signInWithApple()
                                    }
                            }
                            Button(action: {
                                viewModel.goToRegister = true
                            }) {
                                Text("login.dont_have_account".localized())
                                    .font(.montserrat(.medium, size: 15)) +
                                Text("login.register_now".localized())
                                    .font(.montserrat(.bold, size: 15))
                            }
                            .foregroundColor(.black)
                        }
                    }
                }
                .navigationDestination(isPresented: $viewModel.goToPasswordReset) {
                    PasswordResetView()
                }
            }
            
            .fullScreenCover(isPresented: $viewModel.goToHealthPermission) {
                NavigationView {
                    HealthKitPermissionView()
                }
                .environmentObject(
                    BindingRouter($viewModel.goToHealthPermission)
                )
            }
            .fullScreenCover(isPresented: $viewModel.goToRegister) {
                NavigationView {
                    RegisterView()
                }
                .environmentObject(
                    BindingRouter($viewModel.goToRegister)
                )
            }
            
            .navigationBarBackButtonHidden(true)
           
            .fsAlertModifier(
                isPresented: $viewModel.showAlert,
                title: "login.alert_wrong_credentials_title".localized(),
                message: errorMessage,
                confirmButtonText: "login.alert_try_again".localized(),
                confirmAction: {
                    withAnimation {
                        showAlert = false
                    }
                }
            )
            .fsAlertModifier(
                isPresented: $showAlert,
                title: "login.alert_wrong_credentials_title".localized(),
                message: errorMessage,
                confirmButtonText: "login.alert_try_again".localized(),
                confirmAction: {
                    withAnimation {
                        showAlert = false
                    }
                }
            )
        }
    }
    func signIn() {
        Auth.auth().signIn(withEmail: validationModel.email, password: validationModel.password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                self.showAlert = true
            } else {
                errorMessage = "User signed in successfully!"
                AuthenticationManager.shared.logIn()
                validationModel.email = ""
                validationModel.password = ""
            }
        }
    }
}


struct SigninView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserInputModel())
    }
}
