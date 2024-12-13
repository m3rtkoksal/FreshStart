//
//  AllergenItemView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct AllergenItemView: View {
    var allergen: Allergen
    var selectedAllergen: Set<String>
    let nameWidth = UIScreen.screenWidth * 0.28
    let typeWidth = UIScreen.screenWidth * 0.2
    let severityWidth = UIScreen.screenWidth * 0.15
    let iconWidth = UIScreen.screenWidth * 0.1
    
    private var isSelected: Bool {
        selectedAllergen.contains(allergen.id ?? "")
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: UIScreen.screenWidth, height: 1)
                .background(Color.black.opacity(0.3))
            HStack {
                Text(allergen.id?.capitalized.localized() ?? "")
                    .frame(width: nameWidth, alignment: .leading)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                Divider()
                    .frame(height: 36)
                    .background(Color.black.opacity(0.3))
                Text(allergen.type?.localized() ?? "")
                    .frame(width: typeWidth, alignment: .center)
                Divider()
                    .frame(height: 36)
                    .background(Color.black.opacity(0.3))
                Text("\(allergen.severityLevel ?? 0)")
                    .frame(width: severityWidth, alignment: .center)
                Divider()
                    .frame(height: 36)
                    .background(Color.black.opacity(0.3))
                HStack {
                    Image(isSelected ? "selectedPlus" : "deselectedPlus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: iconWidth, alignment: .trailing)
                Spacer()
            }
            .padding(.leading, 20)
            .font(.montserrat(.medium, size: 12))
            .foregroundColor(.black)
            .frame(maxWidth: UIScreen.screenWidth)
        }
        .frame(height: 35)
    }
}
