//
//  ReCreateMealElementView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseAuth

struct ReCreateMealButton: View {
    @StateObject private var openAIManager = OpenAIManager()
    @StateObject var viewModel: DiaryVM
    var dietPlanId: String
    @Binding var meal: Meal
    @Binding var shouldRegenerateRecipe: Bool
    var index: Int
    
    var body: some View {
        Button(action: {
            viewModel.generateAndSaveNewMeal(dietPlanId: dietPlanId, meal: meal, index: index) { newMeal in
                DispatchQueue.main.async {
                    if let updatedMeal = newMeal {
                        self.meal = updatedMeal
                    }
                    viewModel.updateMaxMealCountInFirestore(userId: Auth.auth().currentUser?.uid ?? "",
                                                            maxMealCount: viewModel.maxMealCount)
                    
                    self.shouldRegenerateRecipe = true
                }
            }
        }) {
            VStack(spacing: 0) {
                Divider()
                    .frame(height: 1)
                    .background(Color.black)
                Text("Recreate this meal")
                    .frame(maxWidth: .infinity)
                    .frame(height: 33)
                    .background(Color.mkOrange.opacity(0.5))
                    .font(.montserrat(.semiBold, size: 12))
                    .foregroundColor(.black)
                    .clipShape(
                        .rect(bottomLeadingRadius: 30))
            }
            .background(Color.clear)
        }
        
        .padding(.leading, 21)
        .conditionalOpacityAndDisable(isEnabled: viewModel.maxMealCount > 0 &&
                                      ProfileManager.shared.user.isPremium == true &&
                                      ProfileManager.shared.user.subscriptionEndDate > Date())
        .onAppear {
            viewModel.fetchMaxCountFromFirestore()
        }
    }
}
