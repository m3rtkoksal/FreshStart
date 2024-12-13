//
//  ActivityElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct ActivityElement: View {
    var title: String
    var subtitle: String
    var isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title.localized())
                    .foregroundStyle(.black)
                    .font(.montserrat(.bold, size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
            Text(subtitle.localized())
                    .foregroundStyle(Color.black)
                    .font(.montserrat(.medium, size: 10))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        .padding()
        .background(isSelected ? Color.mkPurple.opacity(0.5) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.black : Color.black, lineWidth: 1)
        )
        .shadow(color: Color(red: 0.51, green: 0.74, blue: 0.62, opacity: 0.3), radius: 10, x: 0, y: 0)
        .padding(.horizontal,20)
    }
}
