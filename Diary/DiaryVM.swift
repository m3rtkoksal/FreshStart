//
//  DiaryVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUICore

class DiaryVM: BaseViewModel {
    @StateObject private var openAIManager = OpenAIManager()
    @Published var mealItems: [String] = []
    @Published var maxMealCount: Int = 0
    @Published var maxPlanCount: Int = 0
    @Published var goToSavedPlanView: Bool = false
    @Published var goToCreateNewPlan: Bool = false
    @Published var goToEditPlan: Bool = false
    @Published var goToRecipeView: Bool = false
    @Published var savedRecipe: String = ""
    @Published var dietPlan = DietPlan()
    private let db = Firestore.firestore()
    private let userId = Auth.auth().currentUser?.uid
    @Published var startMinY: CGFloat = 0
    @Published var offset: CGFloat = 0
    @Published var headerOffset: CGFloat = 0
    @Published var topScrollOffset: CGFloat = 0
    @Published var bottomScrollOffset: CGFloat = 0
    private var hasUsedFallback = false
    @Published var recipe = Recipe()
    @Published var purpose: String?
    @Published var mealTitle: String = ""
    @Published var nutrients: TotalNutrients?
    
    var mealIcons: [String] {
        [
            "Meal1",
            "Meal2",
            "Meal3",
            "Meal4",
            "Meal5",
            "Meal6",
            "Meal1",
            "Meal2",
            "Meal3"
        ]
    }
    func calculateTotalNutrients(selectedMeals: Set<Meal>) -> TotalNutrients? {
        guard let initialNutrients = self.dietPlan.totalNutrients else { return nil }
        
        let selectedNutrients = selectedMeals.reduce(TotalNutrients()) { partialResult, meal in
            guard let mealNutrients = meal.nutrients else { return partialResult }
            return TotalNutrients(
                kcal: partialResult.kcal + mealNutrients.kcal,
                protein: partialResult.protein + mealNutrients.protein,
                carbohydrate: partialResult.carbohydrate + mealNutrients.carbohydrate,
                fat: partialResult.fat + mealNutrients.fat
            )
        }
        return TotalNutrients(
            kcal: initialNutrients.kcal - selectedNutrients.kcal,
            protein: initialNutrients.protein - selectedNutrients.protein,
            carbohydrate: initialNutrients.carbohydrate - selectedNutrients.carbohydrate,
            fat: initialNutrients.fat - selectedNutrients.fat
        )
    }
    
    func deleteDietPlanEntry(dietPlan: DietPlan, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let id = dietPlan.id, !id.isEmpty else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Diet plan ID is missing."])))
            return
        }
        
        let db = Firestore.firestore()
        db.collection("dietPlans").document(id).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
                self.showIndicator = false
            }
        }
    }
    
    func updateMaxMealCountInFirestore(userId: String, maxMealCount: Int) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["maxMealCount": maxMealCount - 1], merge: true) { error in
            if error != nil {
            } else {
            }
        }
    }
    
    func updateMaxPlanCountInFirestore(userId: String, maxPlanCount: Int) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData(["maxPlanCount": maxPlanCount], merge: true) { error in
            if error != nil {
            } else {
            }
        }
    }
    
    func fetchMaxCountFromFirestore() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            
            if let maxMealCount = document.get("maxMealCount") as? Int,
               let maxPlanCount = document.get("maxPlanCount") as? Int {
                DispatchQueue.main.async {
                    self.maxMealCount = maxMealCount
                    self.maxPlanCount = maxPlanCount
                }
            }
        }
    }
    
    func saveSelectedMeals(dietPlanId: String, selectedMeals: Set<String>, completion: @escaping (Error?) -> Void) {
        guard let userId = userId else {
            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let data = Array(selectedMeals)
        db.collection("users").document(userId).collection("dietPlans").document(dietPlanId).updateData([
            "selectedMeals": data
        ]) { error in
            completion(error)
        }
    }
    
    func loadSelectedMeals(dietPlanId: String, completion: @escaping (Set<String>?, Error?) -> Void) {
        guard let userId = userId else {
            completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        db.collection("users").document(userId).collection("dietPlans").document(dietPlanId).getDocument { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists, let data = document.data(), let selectedMeals = data["selectedMeals"] as? [String] {
                completion(Set(selectedMeals), nil)
            } else {
                completion(Set<String>(), nil)
            }
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
            
            guard let data = document?.data(),
                  let recipes = data["recipes"] as? [String: Any],
                  let recipeData = recipes[String(index)] as? [String: Any] else {
                print("Recipe not found for index \(index)")
                completion(false)
                return
            }
            
            do {
                let recipeDataJSON = try JSONSerialization.data(withJSONObject: recipeData)
                let recipe = try JSONDecoder().decode(Recipe.self, from: recipeDataJSON)
                self.recipe = recipe
                self.mealTitle = recipe.name
                // Fetch the meal nutrients from the meals array
                if let meals = data["meals"] as? [[String: Any]], let meal = meals.first {
                    if let mealNutrients = meal["nutrients"] as? [String: Any] {
                        self.nutrients = TotalNutrients(from: mealNutrients)
                    }
                }
                
                if let purpose = data["purpose"] as? String {
                    self.purpose = purpose
                }
                self.showIndicator = false
                completion(true)
            } catch {
                print("Error decoding recipe data: \(error)")
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
    
    
    func saveNewMealToFirestore(dietPlanId: String, index: Int, meal: Meal, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let dietPlanRef = db.collection("dietPlans").document(dietPlanId)
        
        // First, fetch the current meals array
        dietPlanRef.getDocument { document, error in
            if let error = error {
                print("Error fetching diet plan for update: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            // Get the current meals array, modify the specified index, and save it back
            if var meals = document?.data()?["meals"] as? [[String: Any]], meals.indices.contains(index) {
                do {
                    let mealData = try JSONEncoder().encode(meal)
                    if let mealDictionary = try JSONSerialization.jsonObject(with: mealData, options: []) as? [String: Any] {
                        meals[index] = mealDictionary // Update the targeted meal at the specified index
                        
                        // Save the updated meals array back to Firestore
                        dietPlanRef.updateData(["meals": meals]) { error in
                            if let error = error {
                                print("Error saving updated meals array to Firestore: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("Meal at index \(index) updated successfully.")
                                completion(true)
                            }
                        }
                    }
                } catch {
                    print("Failed to encode meal: \(error)")
                    completion(false)
                }
            } else {
                print("Meals array does not exist or index is out of bounds.")
                completion(false)
            }
        }
    }
    
    func generateRecipeFromMeal(meal: Meal, completion: @escaping (Recipe?) -> Void) {
        openAIManager.generateRecipePrompt(meal: meal) { responseRecipe in
            DispatchQueue.main.async {
                completion(responseRecipe)
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
                    completion(generatedRecipe)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    func generateAndSaveNewMeal(dietPlanId: String, meal: Meal, index: Int, completion: @escaping (Meal?) -> Void) {
        self.showIndicator = true
        OpenAIManager.shared.generateNewMealPrompt(meal: meal) { responseMeals in
            guard let responseMeals = responseMeals else {
                completion(nil)
                self.showIndicator = false
                return
            }
            
            // Save the new meal to Firestore
            self.saveNewMealToFirestore(dietPlanId: dietPlanId, index: index, meal: responseMeals) { success in
                self.showIndicator = false
                if success {
                    print("Meal saved successfully:")
                    print(responseMeals)
                    self.showIndicator = false
                    self.fetchDietPlan(byId: dietPlanId) { success in
                        if success {
                            print("Updated diet plan set as default.")
                        } else {
                            print("Failed to fetch updated diet plan.")
                        }
                    }
                    completion(responseMeals)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func fetchDietPlan(byId planId: String, completion: @escaping (Bool) -> Void) {
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
                    self.showIndicator = false
                    DispatchQueue.main.async {
                        // Update default diet plan
                        ProfileManager.shared.setDefaultDietPlan(dietPlan)
                        self.showIndicator = false
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

    
    func fetchDietPlan(completion: @escaping (DietPlan?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found.")
            completion(nil)
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            // Try to fetch the default diet plan ID from the user's document
            if let data = snapshot?.data(),
               let planId = data["defaultDietPlanId"] as? String {
                // If a default plan ID exists, fetch the diet plan
                Firestore.firestore().collection("dietPlans").document(planId).getDocument { planSnapshot, planError in
                    if let planError = planError {
                        print("Error fetching diet plan: \(planError.localizedDescription)")
                        completion(nil)
                        return
                    }
                    if let planSnapshot = planSnapshot, planSnapshot.exists, let planData = planSnapshot.data() {
                        do {
                            var dietPlan = try Firestore.Decoder().decode(DietPlan.self, from: planData)
                            dietPlan.id = planSnapshot.documentID
                            completion(dietPlan)
                        } catch {
                            print("Error decoding diet plan: \(error.localizedDescription)")
                            completion(nil)
                        }
                    } else {
                        print("Diet plan not found for ID: \(planId)")
                        completion(nil)
                    }
                }
            } else {
                // If no default diet plan ID, fallback to ProfileManager.shared.user.defaultDietPlanId
                let fallbackPlanId = ProfileManager.shared.user.defaultDietPlanId ?? ""
                print("Fallback plan ID: \(fallbackPlanId)")
                
                if !fallbackPlanId.isEmpty && !self.hasUsedFallback {
                    self.hasUsedFallback = true
                    Firestore.firestore().collection("dietPlans").document(fallbackPlanId).getDocument { planSnapshot, planError in
                        if let planError = planError {
                            print("Error fetching fallback diet plan: \(planError.localizedDescription)")
                            completion(nil)
                            return
                        }
                        
                        if let planSnapshot = planSnapshot, planSnapshot.exists, let planData = planSnapshot.data() {
                            do {
                                var dietPlan = try Firestore.Decoder().decode(DietPlan.self, from: planData)
                                dietPlan.id = planSnapshot.documentID
                                self.showIndicator = false
                                completion(dietPlan)
                            } catch {
                                print("Error decoding fallback diet plan: \(error.localizedDescription)")
                                completion(nil)
                            }
                        } else {
                            print("Fallback diet plan not found for ID: \(fallbackPlanId)")
                            completion(nil)
                        }
                    }
                } else {
                    print("No default diet plan and no fallback available.")
                    completion(nil)
                }
            }
        }
    }
}
