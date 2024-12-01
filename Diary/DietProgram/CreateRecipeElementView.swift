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
    
    @StateObject private var openAIManager = OpenAIManager()
    @State private var recipe: Recipe?
    @StateObject var viewModel: DiaryVM
    @State private var isLoading = false // Loading indicator for the button
    @State private var isRecipeLoaded = false
    @Binding var shouldRegenerateRecipe: Bool
    
    var body: some View {
        NavigationStack {
            Button(action: {
                isLoading = true
                if shouldRegenerateRecipe {
                    shouldRegenerateRecipe = false
                    generateNewRecipe()
                }
                viewModel.fetchRecipeFromFirestore(dietPlanId: dietPlanId, index: index) { existingRecipe in
                    if let recipe = existingRecipe {
                        DispatchQueue.main.async {
                            self.recipe = recipe
                            self.isRecipeLoaded = true
                        }
                    } else {
                        generateNewRecipe()
                    }
                    isLoading = false
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
            
            .navigationDestination(isPresented: $isRecipeLoaded) {
                RecipeView(index: index, dietPlanId: dietPlanId, mealTitle: meal.name)
            }
        }
       
    }
    
    private func generateNewRecipe() {
        viewModel.generateAndSaveNewRecipe(dietPlanId: dietPlanId, meal: meal, index: index) { newRecipe in
            DispatchQueue.main.async {
                if let newRecipe = newRecipe {
                    self.recipe = newRecipe
                    self.isRecipeLoaded = true
                } else {
                    // Handle failure case
                    self.isRecipeLoaded = false
                }
                self.isLoading = false
            }
        }
    }
}
