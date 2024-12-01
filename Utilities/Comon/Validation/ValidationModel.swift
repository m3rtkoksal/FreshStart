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
        self.emailValidator = DefaultTextValidator(predicate: ValidatorHelper.emailPredicate, validationMessage: "Invalid email format")
        self.passwordValidator = DefaultTextValidator(predicate: ValidatorHelper.passwordPredicate, validationMessage: "Password must be at least 8 characters long and contain a number and special character")
        self.firstNameValidator = DefaultTextValidator(predicate: ValidatorHelper.firstNamePredicate, validationMessage: "First name must be 2-30 characters long and use Turkish characters")
        self.lastNameValidator = DefaultTextValidator(predicate: ValidatorHelper.lastNamePredicate, validationMessage: "Last name must be 2-30 characters long and use Turkish characters")
        self.usernameValidator = DefaultTextValidator(predicate: ValidatorHelper.usernamePredicate, validationMessage: "Username must be 2-30 characters long and can contain Turkish characters, numbers, and dashes")
        self.dateValidator = DefaultTextValidator(predicate: ValidatorHelper.datePredicate, validationMessage: "Date must be in the format dd/MM/yyyy")
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
