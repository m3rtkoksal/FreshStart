//
//  MealCardPreviewElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct MealCardPreviewElement: View {
    var meal: Meal
    var icon: String
    @State private var cardHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(Color.white)
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.black, lineWidth: 1)
                    .padding(.horizontal, 20)
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
                                            .frame(width: 4, height: 4)
                                        Text("\(meal.items[index].item) - \(meal.items[index].quantity)")
                                            .foregroundColor(.black)
                                            .font(.montserrat(.medium, size: 12))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .fixedSize(horizontal: false, vertical: true)
                                    .background(GeometryReader { geometry in
                                        Color.clear.onAppear {
                                            updateCardHeight(with: geometry.size.height * 1.1)
                                        }
                                    })
                                }
                                .padding(.leading, 33)
                            }
                            Spacer()
                        }
                            .padding(.horizontal, 20)
                    )
            }
        }
        .background(Color.clear)
        .frame(height: cardHeight)
        
        .onAppear {
            resetCardHeight()
        }
    }
    
    private func updateCardHeight(with itemHeight: CGFloat) {
        DispatchQueue.main.async {
            // Dynamically add item height to the total card height
            cardHeight += itemHeight
        }
    }
    
    private func resetCardHeight() {
        // Start with base height
        cardHeight = Constant.imageHeight + Constant.bottomPreviewPadding
    }
}
