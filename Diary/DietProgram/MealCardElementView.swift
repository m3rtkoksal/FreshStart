//
//  MealCardElementView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct MealCardElementView: View {
    var meal: Meal
    var icon: String
    var selectedMeals: Set<Meal>
    @State private var cardHeight: CGFloat = 0
    @State private var hasCalculatedHeight = false
    private var isSelected: Bool {
        selectedMeals.contains(meal)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(Color.white)
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.black, lineWidth: 1)
                
                    .overlay(
                        VStack(alignment: .leading) {
                            HStack(alignment: .center, spacing: 10) {
                                Image(icon)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text(meal.name)
                                    .underline()
                                    .font(.montserrat(.semiBold, size: 18))
                                Spacer()
                            }
                            .padding(.leading, 10)
                            .padding(.top, 10)
                            ForEach(meal.items.indices, id: \.self) { index in
                                VStack(spacing: 2) {
                                    HStack {
                                        Circle()
                                            .fill(index % 2 == 0 ? Color.mkOrange : Color.mkPurple)
                                            .frame(width: 2, height: 2)
                                        Text("\(meal.items[index].item) - \(meal.items[index].quantity)")
                                            .foregroundColor(.black)
                                            .font(.montserrat(.medium, size: 12))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .background(GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            if !hasCalculatedHeight {
                                                // Only update the height once when the view appears
                                                updateCardHeight(with: geometry.size.height)
                                            }
                                        }
                                    })
                                }
                                .padding(.leading, 33)
                            }
                            Spacer()
                        }
                            .padding(.trailing, 40)
                    )
                    .overlay(
                        Image(isSelected ? "selectedMeal" : "deselectedMeal")
                        ,
                        alignment: .topTrailing
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
        
        }
        .background(Color.clear)
        .cornerRadius(10)
        .frame(height: cardHeight)
        
        .onChange(of: meal) { newMeal in
            resetCardHeight()
        }
        .onAppear {
            resetCardHeight()
        }
    }
    
    private func updateCardHeight(with itemHeight: CGFloat) {
        // Only update the height once
        if !hasCalculatedHeight {
            DispatchQueue.main.async {
                cardHeight += itemHeight
                hasCalculatedHeight = true
            }
        }
    }
    
    private func resetCardHeight() {
        // Reset only when needed (e.g., when meal changes)
        if !hasCalculatedHeight {
            cardHeight = Constant.bottomPadding + Constant.imageHeight
            let itemHeight: CGFloat = 18
            cardHeight += CGFloat(meal.items.count) * itemHeight
        }
    }
}
