//
//  ChangeNameView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

enum FieldType {
    case firstName
    case surname
    case username
}

struct ChangeNameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChangeNameVM
    @StateObject private var validationModel = ValidationModel()
    
    private var fieldType: FieldType
    
    init(fieldType: FieldType) {
        _viewModel = StateObject(wrappedValue: ChangeNameVM())
        self.fieldType = fieldType
        
        // Set the appropriate validator based on the field type
        switch fieldType {
        case .firstName:
            validationModel.firstNameValidator = DefaultTextValidator(predicate: ValidatorHelper.firstNamePredicate)
        case .surname:
            validationModel.lastNameValidator = DefaultTextValidator(predicate: ValidatorHelper.lastNamePredicate)
        case .username:
            validationModel.usernameValidator = DefaultTextValidator(predicate: ValidatorHelper.usernamePredicate)
        }
    }
    
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack {
                DGTitle(
                    title: "Information of You",
                    subtitle: "You can change your information in here")
                ValidatingTextField(
                    text: getFieldBinding(),
                    validator: getFieldValidator(),
                    placeholder: getPlaceholder()
                )
                Spacer()
                DGButton(text: "Update", backgroundColor: .mkOrange) {
                    switch fieldType {
                    case .firstName:
                        viewModel.updateFirstName(newFirstName: validationModel.firstName)
                        ProfileManager.shared.setUserFirstName(validationModel.firstName)
                    case .surname:
                        viewModel.updateSurname(newSurname: validationModel.lastName)
                        ProfileManager.shared.setUserSurname(validationModel.lastName)
                    case .username:
                        viewModel.updateUsername(newUsername: validationModel.username)
                        ProfileManager.shared.setUserName(validationModel.username)
                    }
                    self.dismiss()
                }
                .conditionalOpacityAndDisable(isEnabled: isFieldValid())
            }
            .navigationBarBackButtonHidden()
            .navigationBarItems(
                leading:
                    DGBackButton()
            )
        }
    }
    
    private func getFieldBinding() -> Binding<String> {
        switch fieldType {
        case .firstName: return $validationModel.firstName
        case .surname: return $validationModel.lastName
        case .username: return $validationModel.username
        }
    }
    
    private func getFieldValidator() -> DefaultTextValidator {
        switch fieldType {
        case .firstName: return validationModel.firstNameValidator
        case .surname: return validationModel.lastNameValidator
        case .username: return validationModel.usernameValidator
        }
    }
    
    private func getPlaceholder() -> String {
        switch fieldType {
        case .firstName: return ProfileManager.shared.user.firstName ?? "First name"
        case .surname: return ProfileManager.shared.user.lastName ?? "Surname"
        case .username: return ProfileManager.shared.user.userName ?? "Username"
        }
    }
    private func updateFieldValue() {
        switch fieldType {
        case .firstName:
            viewModel.updateFirstName(newFirstName: validationModel.firstName)
            ProfileManager.shared.setUserFirstName(validationModel.firstName)
        case .surname:
            viewModel.updateSurname(newSurname: validationModel.lastName)
            ProfileManager.shared.setUserSurname(validationModel.lastName)
        case .username:
            viewModel.updateUsername(newUsername: validationModel.username)
            ProfileManager.shared.setUserName(validationModel.username)
        }
    }
    private func isFieldValid() -> Bool {
        switch fieldType {
        case .firstName: return validationModel.firstNameValidator.isValid
        case .surname: return validationModel.lastNameValidator.isValid
        case .username: return validationModel.usernameValidator.isValid
        }
    }
}
