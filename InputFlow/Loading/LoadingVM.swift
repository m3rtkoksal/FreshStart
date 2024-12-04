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
    @Published var username: String = ""
    @Published var showFailAlert: Bool = false
    
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
    
    func updateMaxCountFirestore(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let updatedMaxPlanCount = max(maxPlanCount - 1, 0)
        let updatedMaxMealCount = max(maxMealCount, 1)
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.updateData(["maxPlanCount": updatedMaxPlanCount])
        userRef.updateData(["maxMealCount": updatedMaxMealCount])
        { error in
            if let error = error {
                print("Error saving maxCount: \(error.localizedDescription)")
                completion(false)
            } else {
                print("maxCount saved successfully.")
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
            
            let maxPlanCount = document?.get("maxPlanCount") as? Int
            let maxMealCount = document?.get("maxMealCount") as? Int
            
            self.maxMealCount = maxMealCount ?? 4
            self.maxPlanCount = maxPlanCount ?? 1
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
        
    func generateAndSetUsername() {
        let randomNumber = String(format: "%05d", Int.random(in: 0...99999))
        self.username = "FreshStarter\(randomNumber)"
        updateUsername(newUsername: self.username, userId: Auth.auth().currentUser?.uid ?? "") { successUsername in
           print("Usrename updated: \(successUsername)")
        }
    }

    func updateUsername(newUsername: String, userId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("users")
        
        // Check if the current user has a username, if not, assign a default one
        usersCollection.document(userId).getDocument { (document, error) in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if document?.data()?["username"] == nil {
                // If the user doesn't have a username, set the new one
                usersCollection.document(userId).updateData(["username": newUsername]) { error in
                    if let error = error {
                        print("Error updating username: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Username updated successfully to \(newUsername).")
                        completion(true)
                    }
                }
            } else {
                print("User already has a username: \(newUsername).")
                ProfileManager.shared.setUserName(newUsername)
                completion(true)
            }
        }
    }
}
