//
//  ValidatingTextField.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct ValidatingTextField: View {
    @Binding var text: String
    @ObservedObject var validator: DefaultTextValidator
    var placeholder: String
    
    // State to control when validation should occur (after 3 seconds)
    @State private var shouldValidate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeholder, text: $text)
                .onChange(of: text) { newValue in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        shouldValidate = true
                        validator.validate(text: text)
                    }
                }
                .padding([.leading, .trailing], 20)
                .frame(height: 46)
                .background(Color.white)
                .border(shouldValidate && !validator.isValid ? Color.red : Color.black, width: 1)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .font(.montserrat(.medium, size: 14))

            if shouldValidate && !text.isEmpty && !validator.isValid {
                Text(validator.validationMessage)
                    .foregroundColor(.red)
                    .font(.montserrat(.medium, size: 8))
            }
        }
        .padding(.horizontal,20)
    }
}
