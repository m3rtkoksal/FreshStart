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
                            title: "registration.title".localized(),
                            subtitle: "registration.subtitle".localized(),
                            bottomPadding: 10
                        )
                        VStack(spacing: 10){
                            ValidatingTextField(text: $validationModel.firstName,
                                                validator: validationModel.firstNameValidator,
                                                placeholder: "registration.first_name_placeholder".localized())
                            .autocapitalization(.none)
                            ValidatingTextField(text: $validationModel.lastName,
                                                validator: validationModel.lastNameValidator,
                                                placeholder: "registration.last_name_placeholder".localized())
                            .autocapitalization(.none)
                            ValidatingTextField(text: $validationModel.email,
                                                validator: validationModel.emailValidator,
                                                placeholder: "registration.email_placeholder".localized())
                            .autocapitalization(.none)
                            
                            SecureValidatingTextField(text: $validationModel.password,
                                                      validator: validationModel.passwordValidator,
                                                      placeholder: "registration.password_placeholder".localized())
                            VStack(spacing: 40) {
                                FreshStartButton(text: "registration.create_account_button".localized(), backgroundColor: .mkOrange) {
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
                                Spacer(minLength: geometry.size.height * 0.1)
                                FreshStartDivider(title: "registration.or_register_with".localized())
                                VStack(spacing: 10) {
                                    FreshStartButton(
                                        image: "google-icon",
                                        text: "registration.connect_with_google_button".localized(),
                                        backgroundColor: .white) {
                                            viewModel.signUpWithGoogle()
                                        }
                                    FreshStartButton(
                                        image: "apple_icon",
                                        text: "registration.connect_with_apple_button".localized(),
                                        backgroundColor: .mkPurple,
                                        textColor: .white) {
                                            viewModel.signUpWithApple()
                                        }
                                }
                                
                                Button(action: {
                                    viewModel.goToLogin = true
                                }) {
                                    Text("registration.already_have_account".localized())
                                        .font(.montserrat(.medium, size: 15)) +
                                    Text("registration.login_button".localized())
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
            .fsAlertModifier(
                isPresented: $showAlert,
                title: errorTitle.localized(),
                message: errorMessage.description,
                confirmButtonText: "registration.done_button".localized(),
                confirmAction: {
                    withAnimation {
                        showAlert = false
                        self.viewModel.showIndicator = false
                        if errorTitle.contains("success") {
                            self.viewModel.showIndicator = false
                            viewModel.goToHealthPermission = true
                        }
                    }
                }
            )
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
                HealthKitPermissionView()
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
                    "maxMealCount": 4
                ]) { err in
                    if let err = err {
                        self.errorTitle = "Error saving user data"
                        self.errorMessage = err.localizedDescription
                        self.showAlert = true
                    } else {
                        self.errorTitle = "User signed up and data saved successfully!"
                        self.errorMessage = ""
                        self.showAlert = true
                        self.viewModel.showIndicator = false
                    }
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
