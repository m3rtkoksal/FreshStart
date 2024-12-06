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
    @State private var temporaryMeal: Meal?
    @Binding var selectedMeals: Set<Meal>
    
    var body: some View {
        Button(action: {
            self.viewModel.showIndicator = true
            let oldMeal = viewModel.dietPlan.meals[index]
            selectedMeals.remove(oldMeal)
            MealManager.shared.saveSelectedMeals(dietPlanId: viewModel.dietPlan.id ?? "", selectedMeals: selectedMeals)
            viewModel.generateAndSaveNewMeal(dietPlanId: dietPlanId, meal: meal, index: index) { newMeal in
                if let updatedMeal = newMeal {
                    selectedMeals.insert(updatedMeal)
                    MealManager.shared.saveSelectedMeals(dietPlanId: viewModel.dietPlan.id ?? "", selectedMeals: selectedMeals)
                    withAnimation {
                        self.temporaryMeal = updatedMeal
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.meal = updatedMeal
                        self.temporaryMeal = nil
                    }
                    viewModel.updateMaxMealCountInFirestore(userId: Auth.auth().currentUser?.uid ?? "",
                                                            maxMealCount: viewModel.maxMealCount)
                    self.shouldRegenerateRecipe = true
                }
                self.viewModel.showIndicator = false
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
        .conditionalOpacityAndDisable(isEnabled: viewModel.maxMealCount > 0)
        //        &&
        //                                      ProfileManager.shared.user.isPremium == true &&
        //                                      ProfileManager.shared.user.subscriptionEndDate > Date()
        .onAppear {
            viewModel.fetchMaxCountFromFirestore()
        }
    }
}
