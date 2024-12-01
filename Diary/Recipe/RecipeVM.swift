//
//  RecipeVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class RecipeVM: BaseViewModel {
    @Published var recipe: Recipe?
    @Published var purpose: String?
    @Published var mealTitle: String = ""
    @Published var nutrients: TotalNutrients?

    func fetchRecipeFromFirestore(dietPlanId: String, index: Int, completion: @escaping (Recipe?) -> Void) {
        self.showIndicator = true
        let db = Firestore.firestore()
        let docRef = db.collection("dietPlans").document(dietPlanId)

        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(nil)
                return
            }

            guard let data = document?.data(),
                  let recipes = data["recipes"] as? [String: Any],
                  let recipeData = recipes[String(index)] as? [String: Any] else {
                print("Recipe not found for index \(index)")
                completion(nil)
                return
            }

            do {
                let recipeDataJSON = try JSONSerialization.data(withJSONObject: recipeData)
                let recipe = try JSONDecoder().decode(Recipe.self, from: recipeDataJSON)

                // Fetch the meal nutrients from the meals array
                if let meals = data["meals"] as? [[String: Any]], let meal = meals.first {
                    if let mealNutrients = meal["nutrients"] as? [String: Any] {
                        self.nutrients = TotalNutrients(from: mealNutrients)
                    }
                }

                if let purpose = data["purpose"] as? String {
                    self.purpose = purpose // Assign the purpose value to the purpose property
                }

                completion(recipe)
                self.showIndicator = false
            } catch {
                print("Error decoding recipe data: \(error)")
                completion(nil)
            }
        }
    }
}
