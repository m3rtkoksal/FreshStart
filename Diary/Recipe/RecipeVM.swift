//
//  RecipeVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 2.12.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUICore

class RecipeVM: BaseViewModel {
    @Published var dietPlan: DietPlan?
    @Published var goToSavedRecipe: Bool = false
    @Published var recipe = Recipe()
    @Published var purpose: String?
    @Published var mealTitle: String = ""
    @Published var nutrients: TotalNutrients?
    @Published var iconName: String?
    @Published var dietPreference: String?
    
    func fetchDietPlan(byId planId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("dietPlans").document(planId).getDocument { document, error in
            if let error = error {
                print("Error fetching diet plan by ID: \(error.localizedDescription)")
                completion(false)
            } else if let document = document, let data = document.data() {
                do {
                    var dietPlan = try document.data(as: DietPlan.self)
                    dietPlan.id = document.documentID
                    dietPlan.createdAt = data["createdAt"] as? Date ?? Date()
                    dietPlan.userId = data["userId"] as? String ?? ""
                    dietPlan.purpose = data["purpose"] as? String ?? ""
                    dietPlan.dietPreference = data["dietPreference"] as? String ?? ""
                    
                    // Extract the purpose to fetch the corresponding icon
                    self.iconName = PurposeInputVM().getIcon(for: dietPlan.purpose ?? "")
                    self.dietPreference = dietPlan.dietPreference
                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } catch {
                    print("Error decoding diet plan: \(error.localizedDescription)")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func saveRecipeToFirestore(dietPlanId: String, index: Int, recipe: Recipe, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let dietPlanRef = db.collection("dietPlans").document(dietPlanId)
        
        // Encode the Recipe into a dictionary
        do {
            let recipeData = try JSONEncoder().encode(recipe)
            if let recipeDict = try JSONSerialization.jsonObject(with: recipeData, options: []) as? [String: Any] {
                dietPlanRef.updateData([
                    "recipes.\(index)": recipeDict
                ]) { error in
                    if let error = error {
                        print("Error saving recipe to Firestore: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Recipe saved successfully under \(index)")
                        completion(true)
                    }
                }
            } else {
                print("Failed to serialize recipe data")
                completion(false)
            }
        } catch {
            print("Error encoding recipe: \(error)")
            completion(false)
        }
    }
    
    func fetchRecipeFromFirestore(dietPlanId: String, index: Int, completion: @escaping (Bool) -> Void) {
        self.showIndicator = true
        let db = Firestore.firestore()
        let docRef = db.collection("dietPlans").document(dietPlanId)
        defer {
            self.showIndicator = false
        }
        
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error)")
                completion(false)
                return
            }
            
            guard let data = document?.data() else {
                print("No document data found")
                completion(false)
                return
            }
            
            // Safely extract meals from the Firestore document
            guard let meals = data["meals"] as? [[String: Any]], meals.count > index else {
                print("Meal not found for index \(index)")
                completion(false)
                return
            }
            
            // Get the meal for the given index
            let mealData = meals[index]
            
            if let nutrients = mealData["nutrients"] as? [String: Any] {
                let kcal = nutrients["kcal"] as? Int ?? 0
                let protein = nutrients["protein"] as? Int ?? 0
                let carbohydrate = nutrients["carbohydrate"] as? Int ?? 0
                let fat = nutrients["fat"] as? Int ?? 0
                
                self.nutrients = TotalNutrients(kcal: kcal, protein: protein, carbohydrate: carbohydrate, fat: fat)
            }
            
            // Decode the meal into a Meal object
            do {
                let mealJSONData = try JSONSerialization.data(withJSONObject: mealData)
                let meal = try JSONDecoder().decode(Meal.self, from: mealJSONData)
                
                // If the recipe doesn't exist, generate it
                if let recipes = data["recipes"] as? [String: Any], let recipeData = recipes[String(index)] {
                    // Recipe exists, decode it
                    let recipeJSONData = try JSONSerialization.data(withJSONObject: recipeData)
                    let recipe = try JSONDecoder().decode(Recipe.self, from: recipeJSONData)
                    self.recipe = recipe
                    self.mealTitle = recipe.name
                    self.goToSavedRecipe = true
                    completion(true)
                } else {
                    // No recipe found, generate a new one
                    self.generateAndSaveNewRecipe(dietPlanId: dietPlanId, meal: meal, index: index) { recipe in
                        if let recipe = recipe {
                            self.recipe = recipe
                            self.mealTitle = recipe.name
                            self.goToSavedRecipe = true
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
            } catch {
                print("Error decoding meal or recipe data: \(error)")
                completion(false)
            }
        }
    }

    func generateAndSaveNewRecipe(dietPlanId: String, meal: Meal, index: Int, completion: @escaping (Recipe?) -> Void) {
        self.showIndicator = true
        OpenAIManager.shared.generateRecipePrompt(meal: meal) { generatedRecipe in
            guard let generatedRecipe = generatedRecipe else {
                completion(nil)
                self.showIndicator = false
                return
            }
            
            // Save the generated recipe to Firestore and then notify
            self.saveRecipeToFirestore(dietPlanId: dietPlanId, index: index, recipe: generatedRecipe) { success in
                self.showIndicator = false
                if success {
                    self.recipe = generatedRecipe
                    self.mealTitle = generatedRecipe.name
                    self.goToSavedRecipe = true
                    completion(generatedRecipe)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
