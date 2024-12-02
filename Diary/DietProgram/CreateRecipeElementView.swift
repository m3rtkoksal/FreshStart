//
//  CreateRecipeElementView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct CreateRecipeElementView: View {
    var dietPlanId: String
    var meal: Meal
    var index: Int
    @State private var recipe: Recipe?
    @StateObject var viewModel: DiaryVM
    @State private var goToSavedRecipe: Bool = false
    @Binding var shouldRegenerateRecipe: Bool
    
    var body: some View {
        Group {
            Button(action: {
                if shouldRegenerateRecipe {
                    shouldRegenerateRecipe = false
                    generateNewRecipe()
                } else {
                    self.goToSavedRecipe = true
                    viewModel.performTaskWithIndicator {
                        viewModel.fetchRecipeFromFirestore(dietPlanId: dietPlanId, index: index) { success in
                        }
                    }
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
        .navigationDestination(isPresented: $goToSavedRecipe) {
            RecipeView(viewModel: self.viewModel)
        }
    }
    
    private func generateNewRecipe() {
        viewModel.performTaskWithIndicator {
            viewModel.generateAndSaveNewRecipe(dietPlanId: dietPlanId, meal: meal, index: index) { newRecipe in
                DispatchQueue.main.async {
                    if let newRecipe = newRecipe {
                        self.recipe = newRecipe
                        self.goToSavedRecipe = true
                    } else {
                        // Handle failure case
                        self.goToSavedRecipe = false
                    }
                }
            }
        }
    }
}
