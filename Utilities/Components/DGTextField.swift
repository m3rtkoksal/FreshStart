//
//  DGTextField.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DGTextField: View {
    @Binding var text: String
    var placeholder: String
    var fontColor: Color
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.montserrat(.medium, size: 14))
            .foregroundColor(fontColor)
            .disableAutocorrection(true)
            .padding(.horizontal, 10)
            .overlay(
                HStack {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.solidGray)
                            .font(.montserrat(.medium, size: 14))
                    }
                    Spacer()
                }
                    .padding(.horizontal, 10)
            )
    }
}
