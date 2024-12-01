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
    
    private var isSelected: Bool {
        selectedAllergen.contains(allergen.id ?? "")
    }
    
    var body: some View {
        VStack {
            Divider()
                .frame(width: UIScreen.screenWidth, height: 1)
                .background(Color.black.opacity(0.3))
            HStack {
                Text(allergen.name?.capitalized ?? "")
                    .frame(width: 100, alignment: .leading)
                Divider()
                    .frame(height: 36)
                    .background(Color.black.opacity(0.3))
                Text(allergen.type ?? "")
                    .frame(width: 100, alignment: .center)
                Divider()
                    .frame(height: 36)
                    .background(Color.black.opacity(0.3))
                Text("\(allergen.severityLevel ?? 0)")
                    .frame(width: 100, alignment: .center)
                Divider()
                    .frame(height: 36)
                    .background(Color.black.opacity(0.3))
                HStack {
                    Image(isSelected ? "selectedPlus" : "deselectedPlus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .frame(width: 42, alignment: .trailing)
                Spacer()
            }
            .padding(.leading, 20)
            .font(.montserrat(.medium, size: 12))
            .foregroundColor(.black)
        }
        .frame(height: 35)
    }
}

#Preview {
    VStack(alignment: .center, spacing: 0) {
        AllergenItemView(allergen: Allergen(name: "Buckwheat", severityLevel: 3, type: "fruit"), selectedAllergen: [])
        AllergenItemView(allergen:Allergen(id: "2", name: "Sunflower seed", severityLevel: 2, type: "Environmental"),selectedAllergen: [])
        AllergenItemView(allergen:Allergen(id: "3", name: "Milk", severityLevel: 1, type: "Food"),selectedAllergen: [])
    }
    
}
