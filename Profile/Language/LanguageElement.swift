//
//  LanguageElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.12.2024.
//

import SwiftUI
import FlagKit

struct LanguageElement: View {
    var language: LanguageType
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(language.string)
                .foregroundStyle(.black)
                .font(.montserrat(.bold, size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
            let flagImage = getFlagImage(for: language)
            Image(uiImage: flagImage)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
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
    }
    
    func getFlagImage(for language: LanguageType) -> UIImage {
        switch language {
        case .TR:
            if let flag = Flag(countryCode: "TR") {
                return flag.image(style: .roundedRect)
            }
        case .EN:
            if let flag = Flag(countryCode: "GB") {
                return flag.image(style: .roundedRect)
            }
        case .UK:
            if let flag = Flag(countryCode: "UA") {
                return flag.image(style: .roundedRect)
            }
        case .ES:
            if let flag = Flag(countryCode: "ES") {
                return flag.image(style: .roundedRect)
            }
        case .FR:
            if let flag = Flag(countryCode: "FR") {
                return flag.image(style: .roundedRect)
            }
        case .DE:
            if let flag = Flag(countryCode: "DE") {
                return flag.image(style: .roundedRect)
            }
        }
        return UIImage()  // Fallback if flag is not found
    }
}
