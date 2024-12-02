//
//  LoadingVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import AuthenticationServices
import FirebaseFirestore
import FirebaseAuth

class LoadingVM: BaseViewModel {
    
    @Published var goToDietProgram = false
    @StateObject private var openAIManager = OpenAIManager()
    @Published var maxPlanCount: Int = 0
    @Published var maxMealCount: Int = 0
    
    func saveDefaultPlanIdToFirestore(planId: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.updateData(["defaultDietPlanId": planId]) { error in
            if let error = error {
                print("Error saving default plan: \(error.localizedDescription)")
            } else {
                print("Default diet plan saved successfully.")
            }
        }
    }
    
    func generateDietPlan(completion: @escaping (DietPlan?) -> Void) {
        openAIManager.generatePrompt { responseDietPlan in
            DispatchQueue.main.async {
                if let responseDietPlan = responseDietPlan {
                    
                    let newDietPlan = DietPlan(
                        id: UUID().uuidString,
                        createdAt: Date(),
                        totalNutrients: responseDietPlan.totalNutrients ?? TotalNutrients(kcal: 0, protein: 0, carbohydrate: 0, fat: 0),
                        meals: responseDietPlan.meals,
                        userId: ProfileManager.shared.user.userId ?? "",
                        purpose: ProfileManager.shared.user.currentPurpose ?? "",
                        dietPreference: ProfileManager.shared.user.dietPreference ?? ""
                    )
                    
                    // Save the diet plan to Firestore
                    self.saveDietPlanToFirestore(newDietPlan, recipes: [])
                    ProfileManager.shared.setDefaultDietPlanId(newDietPlan.id ?? "")
                    self.saveDefaultPlanIdToFirestore(planId: newDietPlan.id ?? "")
                    // Update the current user's diet plans
                    completion(newDietPlan)
                } else {
                    self.openAIManager.alertMessage = "No response meals received. Please try again."
                    self.openAIManager.showAlert = true
                    
                    // Call the completion with nil
                    completion(nil)
                }
            }
        }
    }
    
    func updateMaxPlanCountFirestore(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.updateData(["maxPlanCount": maxPlanCount - 1]) { error in
            if let error = error {
                print("Error saving maxPlanCount: \(error.localizedDescription)")
                completion(false)
            } else {
                print("maxPlanCount saved successfully.")
                completion(true)
            }
        }
    }

    func fetchMaxCountFromFirestore(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching max count: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let document = document, document.exists,
                  let maxPlanCount = document.get("maxPlanCount") as? Int,
                  let maxMealCount = document.get("maxMealCount") as? Int else {
                completion(false)
                return
            }
            self.maxMealCount = maxMealCount
            self.maxPlanCount = maxPlanCount
            print("Fetched max counts successfully.")
            completion(true)
        }
    }
    
    func saveDietPlanToFirestore(_ dietPlan: DietPlan, recipes: [Recipe]) {
        let db = Firestore.firestore()
        let dietPlanRef = db.collection("dietPlans").document(dietPlan.id ?? UUID().uuidString)
        let recipeData = recipes.map { recipe -> [String: Any] in
            return [
                "id": recipe.id ?? UUID().uuidString,
                "name": recipe.name,
                "ingredients": recipe.ingredients.map { ingredient in
                    return [
                        "item": ingredient.item,
                        "quantity": ingredient.quantity
                    ]
                },
                "instructions": recipe.instructions,
                "totalNutrients": [
                    "kcal": recipe.totalNutrients?.kcal ?? 0,
                    "protein": recipe.totalNutrients?.protein ?? 0,
                    "carbohydrate": recipe.totalNutrients?.carbohydrate ?? 0,
                    "fat": recipe.totalNutrients?.fat ?? 0
                ]
            ]
        }
        let totalNutrientsData: [String: Any] = [
            "kcal": dietPlan.totalNutrients?.kcal ?? 0,
            "protein": dietPlan.totalNutrients?.protein ?? 0,
            "carbohydrate": dietPlan.totalNutrients?.carbohydrate ?? 0,
            "fat": dietPlan.totalNutrients?.fat ?? 0
        ]
        let dietPlanData: [String: Any] = [
            "createdAt": dietPlan.createdAt ?? Date(),  // Use current date if createdAt is nil
            "meals": dietPlan.meals.map { meal in
                return [
                    "name": meal.name,
                    "items": meal.items.map { item in
                        return [
                            "item": item.item,
                            "quantity": item.quantity
                        ]
                    },
                    "nutrients": [
                        "kcal": meal.nutrients?.kcal ?? 0,
                        "protein": meal.nutrients?.protein ?? 0,
                        "carbohydrate": meal.nutrients?.carbohydrate ?? 0,
                        "fat": meal.nutrients?.fat ?? 0
                    ]
                ]
            },
            "userId": dietPlan.userId ?? "",  // Make sure userId exists
            "purpose": dietPlan.purpose ?? "",  // Make sure purpose exists
            "dietPreference": dietPlan.dietPreference ?? "",  // Make sure dietPreference exists
            "totalNutrients": totalNutrientsData,
            "recipes": recipeData
        ]
        
        
        dietPlanRef.setData(dietPlanData) { error in
            if let error = error {
                print("Error saving diet plan: \(error.localizedDescription)")
            } else {
                print("Diet plan saved successfully with recipes!")
            }
        }
    }
}
