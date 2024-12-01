//
//  RecipeView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct RecipeView: View {
    @StateObject private var viewModel = RecipeVM()
    var index: Int
    var dietPlanId: String
    var mealTitle: String
    
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator
        ) {
            VStack {
                DGTitle(
                    title: "Your Recipe For \(mealTitle)",
                    subtitle: "",
                    bottomPadding: -10)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        if let recipe = viewModel.recipe {
                            HStack(alignment: .center) {
                                if let iconName = PurposeInputVM().getIcon(for: viewModel.purpose ?? "") {
                                    Image(iconName)
                                        .resizable()
                                        .frame(width: 46, height: 46)
                                }
                                Text(recipe.name)
                                    .font(.montserrat(.bold, size: 20))
                                    .foregroundColor(.black)
                            }
                            HStack {
                                VStack {
                                    Text("Kcal")
                                        .foregroundColor(.mkPurple)
                                    Text("\(viewModel.nutrients?.kcal ?? 0)")
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                VStack {
                                    Text("Protein")
                                        .foregroundColor(.mkPurple)
                                    Text("\(viewModel.nutrients?.protein ?? 0) gr")
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                VStack {
                                    Text("Carbohydrate")
                                        .foregroundColor(.mkPurple)
                                    Text("\(viewModel.nutrients?.carbohydrate ?? 0) gr")
                                        .foregroundColor(.black)
                                }
                                .frame(maxWidth: .infinity)
                                VStack {
                                    Text("Fat")
                                        .foregroundColor(.mkPurple)
                                    Text("\(viewModel.nutrients?.fat ?? 0) gr")
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
                        } else {
                            Text("no recipe available")
                                .font(.montserrat(.regular, size: 12))
                        }
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
                        DGBackButton()
                )
                .onAppear {
                    viewModel.fetchRecipeFromFirestore(dietPlanId: dietPlanId, index: index) { recipe in
                        if let recipe = recipe {
                            viewModel.recipe = recipe
                        } else {
                            // Handle the case where no recipe is found (e.g., show an error message or fallback recipe)
                            print("Recipe not found")
                        }
                    }
                }
        }
    }
}

#Preview {
    RecipeView(index: 1, dietPlanId: "", mealTitle: "")
}
