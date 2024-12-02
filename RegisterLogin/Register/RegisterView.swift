//
//  RegisterView.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//


import SwiftUI
import FirebaseFirestore
import Firebase
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var validationModel = ValidationModel()
    @StateObject private var viewModel = RegisterVM()
    @State private var errorMessage = ""
    @State private var errorTitle = ""
    @State private var showAlert = false
    @State private var choosenItem = FSDropdownItemModel(text: "")
    @State private var showGenderMenu = false
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack {
                        FSTitle(
                            title: "Registiration",
                            subtitle: "Please enter your information to create new account",
                            bottomPadding: 10)
                        VStack(spacing: 10){
                            ValidatingTextField(text: $validationModel.firstName,
                                                validator: validationModel.firstNameValidator,
                                                placeholder: "First name")
                            .autocapitalization(.none)
                            ValidatingTextField(text: $validationModel.lastName,
                                                validator: validationModel.lastNameValidator,
                                                placeholder: "Last name")
                            .autocapitalization(.none)
                            ValidatingTextField(text: $validationModel.email,
                                                validator: validationModel.emailValidator,
                                                placeholder: "Email Address")
                            .autocapitalization(.none)
                            
                            SecureValidatingTextField(text: $validationModel.password,
                                                      validator: validationModel.passwordValidator,
                                                      placeholder: "Password")
                            VStack(spacing: 50) {
                                FreshStartButton(text: "Create Account", backgroundColor: .mkOrange) {
                                    self.viewModel.showIndicator = true
                                    self.signUp(
                                        email: validationModel.email,
                                        password: validationModel.password,
                                        name: validationModel.firstName,
                                        surname: validationModel.lastName
                                    )
                                }
                                .conditionalOpacityAndDisable(
                                    isEnabled: validationModel.emailValidator.isValid &&
                                    validationModel.passwordValidator.isValid &&
                                    validationModel.firstNameValidator.isValid &&
                                    validationModel.lastNameValidator.isValid
                                )
                                Spacer(minLength: geometry.size.height * 0.13)
                                FreshStartDivider(title: "or Register with")
                                VStack(spacing: 10) {
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
                                            viewModel.signUpWithApple()
                                        }
                                }
                                
                                Button(action: {
                                    viewModel.goToLogin = true
                                }) {
                                    Text("Already have an account? ")
                                        .font(.montserrat(.medium, size: 15)) +
                                    Text("Login!")
                                        .font(.montserrat(.bold, size: 15))
                                }
                                .foregroundColor(.black)
                                .padding(.bottom)
                            }
                            .padding(.top, 30)
                        }
                        .frame(width: UIScreen.screenWidth)
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(errorTitle),
                    message: Text(errorMessage.description),
                    dismissButton: .default(Text("OK")) {
                        showAlert = false
                        self.viewModel.showIndicator = false
                        if errorTitle.contains("success") {
                            self.viewModel.showIndicator = false
                            viewModel.goToHealthPermission = true
                        } else {
                            self.viewModel.showIndicator = false
                        }
                    }
                )
            }
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $viewModel.goToLogin) {
                NavigationView {
                   LoginView()
                }
                .environmentObject(
                    BindingRouter($viewModel.goToLogin)
                )
            }
            .fullScreenCover(isPresented: $viewModel.goToHealthPermission) {
                NavigationView {
                   HealthKitPermissionView()
                }
                .environmentObject(
                    BindingRouter($viewModel.goToHealthPermission)
                )
            }
            .onAppear {
                viewModel.fetchMenuItems()
            }
        }
    }
    func signUp(email: String, password: String, name: String, surname: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showAlert = true
            } else if let user = authResult?.user {
                // User is successfully authenticated, now save additional information to Firestore
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "userId": user.uid,
                    "name": name,
                    "surname": surname,
                    "username": "",
                    "email": email,
                    "maxPlanCount": 1,
                    "maxMealCount": 1
                ]) { err in
                    if let err = err {
                        self.errorTitle = "Error saving user data"
                        self.errorMessage = err.localizedDescription
                        self.showAlert = true
                    } else {
                        self.errorTitle = "User signed up and data saved successfully!"
                        self.errorMessage = ""
                        self.showAlert = true
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
