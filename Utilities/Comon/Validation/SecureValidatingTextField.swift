//
//  SecureValidatingTextField.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct SecureValidatingTextField: View {
    @Binding var text: String
    @ObservedObject var validator: DefaultTextValidator
    var placeholder: String
    @State private var isSecureField: Bool = true
    @State private var shouldValidate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .trailing) {
                Group {
                    if isSecureField {
                        SecureField(placeholder, text: $text)
                            .onChange(of: text) { newValue in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    shouldValidate = true
                                    validator.validate(text: text)
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 46)
                            .border(shouldValidate && !validator.isValid ? Color.red : Color.black, width: 1)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.montserrat(.regular, size: 14))
                    } else {
                        TextField(placeholder, text: $text)
                            .onChange(of: text) { newValue in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    shouldValidate = true
                                    validator.validate(text: text)
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 46)
                            .border(shouldValidate && !validator.isValid ? Color.red : Color.black, width: 1)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .font(.montserrat(.regular, size: 14))
                    }
                }

                // Button to toggle password visibility
                Button(action: { isSecureField.toggle() }) {
                    Image(systemName: isSecureField ? "eye.slash" : "eye")
                        .foregroundColor(.mkPurple)
                        .opacity(isSecureField ? 0.3 : 0.8)
                        .padding(.trailing, 16)
                }
                .frame(height: 46)
            }

            if shouldValidate && !text.isEmpty && !validator.isValid {
                Text(validator.validationMessage)
                    .foregroundColor(.red)
                    .font(.montserrat(.medium, size: 8))
            }
        }
        .padding(.horizontal, 20)
    }
}
