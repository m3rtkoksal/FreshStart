//
//  ValidationModel.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

class ValidationModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var birthday: String = ""
    @Published var username: String = ""
    
    @Published var emailValidator: DefaultTextValidator
    @Published var passwordValidator: DefaultTextValidator
    @Published var firstNameValidator: DefaultTextValidator
    @Published var lastNameValidator: DefaultTextValidator
    @Published var usernameValidator: DefaultTextValidator
    @Published var dateValidator: DefaultTextValidator
    
    // Derived property to check if the form is valid
    var isFormValid: Bool {
        emailValidator.isValid && passwordValidator.isValid && firstNameValidator.isValid && lastNameValidator.isValid
    }

    init() {
        self.emailValidator = DefaultTextValidator(
            predicate: ValidatorHelper.emailPredicate,
            validationMessage: "validation.email_invalid".localized()
        )
        self.passwordValidator = DefaultTextValidator(
            predicate: ValidatorHelper.passwordPredicate,
            validationMessage: "validation.password_invalid".localized()
        )
        self.firstNameValidator = DefaultTextValidator(
            predicate: ValidatorHelper.firstNamePredicate,
            validationMessage: "validation.first_name_invalid".localized()
        )
        self.lastNameValidator = DefaultTextValidator(
            predicate: ValidatorHelper.lastNamePredicate,
            validationMessage: "validation.last_name_invalid".localized()
        )
        self.usernameValidator = DefaultTextValidator(
            predicate: ValidatorHelper.usernamePredicate,
            validationMessage: "validation.username_invalid".localized()
        )
        self.dateValidator = DefaultTextValidator(
            predicate: ValidatorHelper.datePredicate,
            validationMessage: "validation.date_invalid".localized()
        )
    }

    // Optionally validate all fields manually
    func validateAllFields() {
        emailValidator.validate(text: email)
        passwordValidator.validate(text: password)
        firstNameValidator.validate(text: firstName)
        lastNameValidator.validate(text: lastName)
        usernameValidator.validate(text: username)
        dateValidator.validate(text: birthday)
    }
}
