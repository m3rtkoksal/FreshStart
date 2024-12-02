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
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator
        ) {
            VStack {
                FSTitle(
                    title: "Your Recipe For \(viewModel.mealTitle)",
                    subtitle: "",
                    bottomPadding: -10)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Image(viewModel.iconName ?? "")
                                .resizable()
                                .frame(width: 46, height: 46)
                            Text(viewModel.mealTitle)
                                .font(.montserrat(.bold, size: 20))
                                .foregroundColor(.black)
                        }
                        HStack {
                            VStack {
                                Text("Kcal")
                                    .foregroundColor(.mkPurple)
                                Text("\(viewModel.mealNutrients?.kcal ?? 0)")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            VStack {
                                Text("Protein")
                                    .foregroundColor(.mkPurple)
                                Text("\(viewModel.mealNutrients?.protein ?? 0) gr")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            VStack {
                                Text("Carbohydrate")
                                    .foregroundColor(.mkPurple)
                                Text("\(viewModel.mealNutrients?.carbohydrate ?? 0) gr")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                            VStack {
                                Text("Fat")
                                    .foregroundColor(.mkPurple)
                                Text("\(viewModel.mealNutrients?.fat ?? 0) gr")
                                    .foregroundColor(.black)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .font(.montserrat(.medium, size: 10))
                        .padding(.vertical, 15)
                        
                        Text("Ingredients:")
                            .font(.montserrat(.medium, size: 14))
                            .padding(.bottom, 5)
                        
                        ForEach(recipe.ingredients.indices, id: \.self) { index in
                            HStack {
                                Circle()
                                    .fill(index % 2 == 0 ? Color.mkOrange : Color.mkPurple)
                                    .frame(width: 2, height: 2) // Adjust the size for visibility
                                Text("\(recipe.ingredients[index].quantity) - \(recipe.ingredients[index].item)")
                                    .font(.montserrat(.regular, size: 16))
                            }
                        }
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                        
                        Text("Instructions:")
                            .font(.montserrat(.medium, size: 14))
                            .padding(.bottom, 5)
                        
                        Text(recipe.instructions)
                            .font(.montserrat(.regular, size: 16))
                            .lineSpacing(8)
                            .foregroundColor(.black)
                            .padding(.bottom, 20)
                            .padding(.horizontal, 10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        Rectangle()
                            .fill(Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    )
                    .padding(20)
                }
            }
            .offset(y: 20)
            Spacer()
                .navigationBarTitle("")
                .navigationBarBackButtonHidden()
                .navigationBarItems(
                    leading:
                        FreshStartBackButton()
                )
        }
        .onAppear {
            viewModel.fetchDietPlan(byId: ProfileManager.shared.user.defaultDietPlanId ?? "") { success in
                if success {
                    print(success)
                }
            }
        }
    }
}
