//
//  ValidatorHelper.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//



import Foundation
import Combine

// Helper class for handling validation logic
class ValidatorHelper {
    
    private static let turkishCharacterSet = "a-zA-ZçÇğĞıİöÖşŞüÜ"
    
    static var firstNamePredicate = NSPredicate(format: "SELF MATCHES %@", "^[\(turkishCharacterSet)\\s]{2,30}$")
    static var lastNamePredicate = NSPredicate(format: "SELF MATCHES %@", "^[\(turkishCharacterSet)\\s]{2,30}$")
    static var usernamePredicate = NSPredicate(format: "SELF MATCHES %@", "^[\(turkishCharacterSet)0-9_\\-\\s]{2,30}$")
    static var agePredicate = NSPredicate(format: "SELF MATCHES %@", "^(?:[0-9]|[1-9][0-9]|1[01][0-9]|120)$")
    static var heightPredicate = NSPredicate(format: "SELF MATCHES %@", "^(?:[0-9]|[1-9][0-9]|[1-2][0-9][0-9]|300)$")
    static var weightPredicate = NSPredicate(format: "SELF MATCHES %@", "^(?:[0-9]|[1-9][0-9]|[1-2][0-9][0-9]|300)$")
    static var emailPredicate = NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$")
    static var passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)[A-Za-z\\d]{8,}$")
    static var datePredicate = NSPredicate(format: "SELF MATCHES %@", "^(0?[1-9]|1\\d|2\\d|3[01])[\\.\\/](0?[1-9]|1[0-2])[\\.\\/](19|20)\\d{2}$")
    
    // Helper function to validate the input text based on predicate and optional minLength
    static func validateText(_ text: String, predicate: NSPredicate, minLength: Int? = nil) -> (isValid: Bool, errorMessage: String) {
        // Check minLength
        if let minLength = minLength, text.count < minLength {
            return (false, "Text should be at least \(minLength) characters long.")
        }
        
        // Check predicate validation
        let isValid = predicate.evaluate(with: text)
        if isValid {
            return (true, "")
        } else {
            return (false, "Invalid input format.")
        }
    }
    
    // Helper function to debounce validation and return appropriate results
    static func debouncedValidation(text: String, predicate: NSPredicate, minLength: Int? = nil, delay: TimeInterval = 0.5) -> AnyPublisher<(isValid: Bool, errorMessage: String), Never> {
        // Create a Combine publisher that will debounce validation checks
        return Just(text)
            .debounce(for: .seconds(delay), scheduler: DispatchQueue.main)
            .map { input in
                return ValidatorHelper.validateText(input, predicate: predicate, minLength: minLength)
            }
            .eraseToAnyPublisher()
    }
}
