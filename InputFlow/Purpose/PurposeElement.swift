//
//  PurposeElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct PurposeElement: View {
    var title: String
    var icon: String
    var isSelected: Bool
    
    var body: some View {
            ZStack {
                Rectangle()
                    .stroke(isSelected ? Color.black : Color.black, lineWidth: 1)
                    .background(isSelected ? Color.mkPurple.opacity(0.5) : Color.clear)
                    .clipShape(Rectangle())
                HStack {
                    Text(title)
                        .foregroundStyle(.black)
                        .font(.montserrat(.semiBold, size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Image(icon)
                        .resizable()
                        .frame(width: 45, height: 45)
                }
                .padding(.horizontal)
            }
            .frame(height: 46)
            .padding(.horizontal, 33)
            .contentShape(Rectangle())
    }
}

#Preview {
    ScrollView {
        VStack(spacing: -10) {
            PurposeElement(title: "Not very active", icon: "loseWeight", isSelected: true)
            PurposeElement(title: "Not very active", icon: "gainFat", isSelected: false)
            PurposeElement(title: "Not very active", icon: "male", isSelected: false)
        }
    }
}
