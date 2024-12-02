//
//  FSValidationTextField.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Combine

struct FSValidationTextField: View {
    var placeholder: String
    var prompt: String
    @Binding var text: String
    @Binding var isCriteriaValid: Bool
    @Binding var showPrompt: Bool
    var style: UIKeyboardType

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                FSTextField(
                    text: $text,
                    placeholder: placeholder,
                    fontColor: .otherGray
                )
                .keyboardType(style)
                .padding(.leading, 3)
                .frame(height: 50)
                .frame(maxWidth: UIScreen.screenWidth / 1.2)
            }
            .onChange(of: text) { newValue in
                isCriteriaValid = validateText(newValue)
                showPrompt = !isCriteriaValid
            }
            .frame(maxWidth: UIScreen.screenWidth / 1.2)
            .background(Color.white)
            .cornerRadius(38)
            .overlay(
                RoundedRectangle(cornerRadius: 38)
                    .strokeBorder(isCriteriaValid ? Color.black : .red, lineWidth: 0.4)
            )
            .shadow(color: Color(red: 0.51, green: 0.74, blue: 0.62, opacity: 0.3), radius: 20, x: 0, y: 0)

            if showPrompt {
                Text(prompt)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.footnote)
                    .foregroundColor(Color.red)
            }
        }
        .padding(.vertical, 5)
    }

    private func validateText(_ text: String) -> Bool {
        // Replace with your validation logic
        !text.isEmpty // Example validation: checks if the text is not empty
    }
}

struct DGValidationTextField_Previews: PreviewProvider {
    @State static var text = ""
    @State static var isCriteriaValid = false
    @State static var showPrompt = true

    static var previews: some View {
        ZStack {
            Color.lightTeal
            FSValidationTextField(
                placeholder: "Enter text",
                prompt: "This is a validation prompt.",
                text: $text,
                isCriteriaValid: $isCriteriaValid,
                showPrompt: $showPrompt,
                style: .default
            )
        }
        .previewLayout(.sizeThatFits)
    }
}
