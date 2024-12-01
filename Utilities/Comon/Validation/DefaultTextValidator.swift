//
//  DefaultTextValidator.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Combine

class DefaultTextValidator: ObservableObject {
    @Published var text: String = ""  // The text being validated
    @Published var isValid: Bool = true  // Boolean to indicate if the text is valid
    @Published var validationMessage: String = ""  // The validation message to display
    
    private var cancellableSet: Set<AnyCancellable> = []  // To store the subscriptions
    
    var predicate: NSPredicate
    var minLength: Int?
    var customValidationMessage: String
    
    // Initializer now accepts validation message
    init(predicate: NSPredicate, minLength: Int? = nil, validationMessage: String = "Invalid input") {
        self.predicate = predicate
        self.minLength = minLength
        self.customValidationMessage = validationMessage
        
        // Subscribe to text changes with debouncing
        $text
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)  // Debounce input for 0.5 seconds
            .sink { [weak self] text in
                guard let self = self else { return }
                
                // Perform validation logic
                self.validate(text: text)
            }
            .store(in: &cancellableSet)
    }
    
    // Perform validation based on the predicate and minLength
    func validate(text: String) {
        let isValid = isValidText(text)
        if !isValid {
            self.validationMessage = customValidationMessage  // Use the custom message
        } else {
            self.validationMessage = ""
        }
        self.isValid = isValid
    }
    
    // Check if the text is valid based on the predicate and minimum length
    private func isValidText(_ text: String) -> Bool {
        let matchesPredicate = predicate.evaluate(with: text)
        let meetsMinLength = minLength == nil || text.count >= minLength!
        
        return matchesPredicate && meetsMinLength
    }
    
    // Optionally, reset validation states
    func reset() {
        self.text = ""
        self.isValid = true
        self.validationMessage = ""
    }
}
