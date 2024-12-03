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
                            title: "Welcome to FreshStart",
                            subtitle: "Hello there, sign in to  continue!")
                        
                        ValidatingTextField(text: $validationModel.email,
                                            validator: validationModel.emailValidator,
                                            placeholder: "Email Address")
                        
                        SecureValidatingTextField(text: $validationModel.password,
                                                  validator: validationModel.passwordValidator,
                                                  placeholder: "Password")
                        .padding(.top, 20)
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                viewModel.goToPasswordReset = true
                            }
                            .font(.montserrat(.semiBold, size: 14))
                            .foregroundColor(.black)
                            .padding(.trailing, 20)
                        }
                        .padding(.top,10)
                        FreshStartButton(text: "Login", backgroundColor: .mkOrange, textColor: .black) {
                            signIn()
                        }
                        .padding(.top, 20)
                        Spacer(minLength: geometry.size.height * 0.2)
                        VStack(spacing: 50){
                            FreshStartDivider(title: "Or Login with")
                            VStack(spacing:10) {
                                FreshStartButton(
                                    image: "google-icon",
                                    text: "Connect with Google",
                                    backgroundColor: .white) {
                                        viewModel.signUpWithGoogle()
                                    }
                                FreshStartButton(
                                    image: "apple_icon",
                                    text: "Connect with Apple  ",
                                    backgroundColor: .mkPurple,
                                    textColor: .white) {
                                        viewModel.signInWithApple()
                                    }
                            }
                            Button(action: {
                                viewModel.goToRegister = true
                            }) {
                                Text("Don’t have an account? ")
                                    .font(.montserrat(.medium, size: 15)) +
                                Text("Register!")
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Wrong email or password"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("Try Again")) {
                        showAlert = false
                    }
                )
            }
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
