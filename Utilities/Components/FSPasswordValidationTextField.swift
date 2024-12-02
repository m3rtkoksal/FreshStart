//
//  DGPasswordValidationTextField.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FSPasswordValidationTextField: View {
    var placeholder: String
    var prompt: String
    @Binding var text: String
    @Binding var isCriteriaValid: Bool
    @Binding var showPrompt: Bool
    
    @State private var isSecureField: Bool = true
    
    private var textFieldStyle: some View {
        isSecureField ? AnyView(
            SecureField("", text: $text)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.solidGray)
                        .font(.montserrat(.medium, size: 14))
                }
        ) : AnyView(
            TextField(placeholder, text: $text)
                .foregroundColor(.black)
                .font(.montserrat(.medium, size: 14))
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                textFieldStyle
                    .padding(.leading, 16)
                    .padding(.trailing, 3)
                    .frame(height: 50)
                    .frame(maxWidth: UIScreen.screenWidth / 1.2)
                
                toggleSecureFieldButton
                    .padding(.trailing, 16)
            }
            .onChange(of: text) { _ in
                isCriteriaValid = validateText(text)
                showPrompt = !isCriteriaValid
            }
            .frame(maxWidth: UIScreen.screenWidth / 1.2)
            .background(Color.white)
            .cornerRadius(38)
            .overlay(
                RoundedRectangle(cornerRadius: 38)
                    .strokeBorder(isCriteriaValid ? Color.black : Color.red, lineWidth: 0.4)
            )
            .shadow(color: Color(red: 0.51, green: 0.74, blue: 0.62, opacity: 0.3), radius: 20, x: 0, y: 0)
            
            if showPrompt {
                Text(prompt)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .foregroundColor(.red)
            }
        }
    }
    
    private var toggleSecureFieldButton: some View {
        Button(action: { isSecureField.toggle() }) {
            Image(systemName: isSecureField ? "eye.slash" : "eye")
                .foregroundColor(.gray)
        }
    }
    
    private func validateText(_ text: String) -> Bool {
        // Your validation logic
        !text.isEmpty // Example validation
    }
}
