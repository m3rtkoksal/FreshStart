//
//  CreateRecipeElementView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct CreateRecipeButton: View {
    var dietPlanId: String
    var meal: Meal
    var index: Int
    @StateObject private var viewModel = RecipeVM()
    @Binding var shouldRegenerateRecipe: Bool
    
    var body: some View {
        Group {
            Button(action: {
                viewModel.showIndicator = true
                if shouldRegenerateRecipe {
                    shouldRegenerateRecipe = false
                    viewModel.generateAndSaveNewRecipe(dietPlanId: dietPlanId, meal: meal, index: index) { recipe in }
                } else {
                    viewModel.fetchRecipeFromFirestore(dietPlanId: dietPlanId, index: index) { success in }
                }
            }) {
                VStack(spacing: 0) {
                    Divider()
                        .frame(height: 1)
                        .background(Color.black)
                    Text("Read the recipe")
                        .frame(maxWidth: .infinity)
                        .frame(height: 33)
                        .background(Color.mkPurple.opacity(0.5))
                        .font(.montserrat(.semiBold, size: 12))
                        .foregroundColor(.black)
                        .clipShape(
                            .rect(bottomTrailingRadius: 30))
                }
                .background(Color.clear)
                
            }
            .padding(.trailing, 20)
        }
        .navigationDestination(isPresented: $viewModel.goToSavedRecipe) {
            RecipeView(viewModel: viewModel, recipe: viewModel.recipe)
        }
    }
}
