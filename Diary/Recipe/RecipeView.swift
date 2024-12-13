//
//  RecipeView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct RecipeView: View {
    @StateObject var viewModel = RecipeVM()
    var recipe: Recipe
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel, background: .solidWhite, showIndicator: $viewModel.showIndicator) {
            VStack {
                FSTitle(title: "your_recipe_for".localized() + " \(viewModel.mealTitle)", subtitle: "", bottomPadding: -10)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        RecipeHeaderView()
                        RecipeNutrientsView()
                        IngredientsView()
                        InstructionsView()
                    }
                    .padding([.horizontal, .vertical], 20)
                    .background(RecipeCardBackground())
                    .padding(20)
                }
            }
            .offset(y: 20)
            
            Spacer()
                .navigationBarTitle("")
                .navigationBarBackButtonHidden()
                .navigationBarItems(leading: FreshStartBackButton())
        }
        .onAppear {
            viewModel.fetchDietPlan(byId: ProfileManager.shared.user.defaultDietPlanId ?? "") { success in
                if success {
                    print(success)
                }
            }
        }
    }
    
    private func RecipeHeaderView() -> some View {
        HStack(alignment: .center) {
            Image(viewModel.iconName ?? "")
                .resizable()
                .frame(width: 46, height: 46)
            Text(viewModel.mealTitle)
                .font(.montserrat(.bold, size: 20))
                .foregroundColor(.black)
        }
    }
    
    private func RecipeNutrientsView() -> some View {
        HStack {
            NutrientView(title: "kcal".localized(), value: "\(viewModel.mealNutrients?.kcal ?? 0)")
            NutrientView(title: "protein".localized(), value: "\(viewModel.mealNutrients?.protein ?? 0) gr")
            NutrientView(title: "carbohydrate".localized(), value: "\(viewModel.mealNutrients?.carbohydrate ?? 0) gr")
            NutrientView(title: "fat".localized(), value: "\(viewModel.mealNutrients?.fat ?? 0) gr")
        }
        .font(.montserrat(.medium, size: 10))
        .padding(.vertical, 15)
    }
    
    private func NutrientView(title: String, value: String) -> some View {
        VStack {
            Text(title)
                .foregroundColor(.mkPurple)
            Text(value)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func IngredientsView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ingredients".localized())
                .font(.montserrat(.medium, size: 14))
                .padding(.bottom, 5)
            
            ForEach(recipe.ingredients.indices, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(index % 2 == 0 ? Color.mkOrange : Color.mkPurple)
                        .frame(width: 2, height: 2)
                    Text("\(recipe.ingredients[index].quantity) - \(recipe.ingredients[index].item)")
                        .font(.montserrat(.regular, size: 16))
                }
                .padding(.leading, 10)
            }
        }
        .padding(.bottom, 10)
    }
    
    private func InstructionsView() -> some View {
        VStack(alignment: .leading) {
            Text("instructions".localized())
                .font(.montserrat(.medium, size: 14))
                .padding(.bottom, 5)
            
            Text(recipe.instructions)
                .font(.montserrat(.regular, size: 16))
                .lineSpacing(8)
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.bottom, 20)
        }
    }
    
    private func RecipeCardBackground() -> some View {
        Rectangle()
            .fill(Color.white)
            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
    }
}
