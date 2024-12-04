//
//  FrequencyElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FrequencyElement: View {
    var numberOfMeals: Int
    var subtitle: String
    var icons: [String]
    var isSelected: Bool
    var onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(numberOfMeals) meals per day: ")
                .foregroundStyle(.black)
                .font(.montserrat(.bold, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(subtitle)
                .foregroundStyle(Color.black)
                .font(.montserrat(.medium, size: 10))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 5)
            HStack(spacing: 10) {
                ForEach(icons, id: \.self) { icon in
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(isSelected ? Color.mkPurple.opacity(0.5) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.black : Color.black, lineWidth: 1)
        )
        .padding(.horizontal,20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
