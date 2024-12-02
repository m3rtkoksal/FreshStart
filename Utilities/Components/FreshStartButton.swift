//
//  DGButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FreshStartButton: View {
    let image: String?
    let text: String
    let backgroundColor: Color
    let textColor: Color
    let action: () -> Void
    
    init(image: String? = nil, text: String, backgroundColor: Color = .clear, textColor: Color = .black, action: @escaping () -> Void) {
        self.image = image
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            content
                .frame(width: UIScreen.screenWidth * 300 / 393, height: 48)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 38))
                .overlay(
                    RoundedRectangle(cornerRadius: 38)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
        .ignoresSafeArea()
    }
    private var content: some View {
        HStack(spacing: 8) {
            if let imageName = image, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            Text(text)
                .font(.montserrat(.bold, size: 17))
                .foregroundColor(textColor)
        }
        .padding()
    }
}

#Preview {
    FreshStartButton(image: "backButton", text: "Yo") {
        print("Button with image tapped")
    }
}

#Preview {
    FreshStartButton(text: "Yo") {
        print("Button without image tapped")
    }
}
