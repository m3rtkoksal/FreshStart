//
//  PromptCreationHelper.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import HealthKit

class PromptCreationHelper {
    
    static func createPrompt() -> String {
        let allergensList = ProfileManager.shared.user.allergens.map { $0.name ?? "Unknown Allergen" }
        return """
        Create a personalized diet plan based on the following guidelines and user data. Make sure to strictly follow the rules, regardless of the user's purpose (e.g., weight loss, muscle gain, etc.). DO NOT change the meal format or any other instructions based on the purpose.
        
        **Rules**:
        1. **JSON Format**:
              The response must be a valid JSON object with the following structure:
              {
                  "totalNutrients": {
                      "kcal": INT,
                      "protein": INT,
                      "carbohydrate": INT,
                      "fat": INT
                  },
                  "meals": [
                      {
                          "name": STRING,
                          "nutrients": {
                              "kcal": INT,
                              "protein": INT,
                              "carbohydrate": INT,
                              "fat": INT
                          },
                          "items": [
                              {"item": STRING, "quantity": STRING},
                              ...
                          ]
                      },
                      ...
                  ]
              }
        
           2. **Total Nutrients**:
              Include the total daily nutrient intake at the start of the JSON object in the "totalNutrients" field.
        
           3. **Meals**:
              Each meal must include a "name" (e.g., "Breakfast"), "nutrients" (summary for the meal), and an "items" array (list of food items with quantities).
        
            4. **Meal Units**:
              Only give meals in grams or pieces
        
           5. **Strict JSON Only**:
              Do not include any additional text, comments, or explanations outside of the JSON object.
        
        **User's Data**:
        - Diet Preference: \(ProfileManager.shared.user.dietPreference != nil ? "\(ProfileManager.shared.user.dietPreference!)" : "none")
        - Allergens: \(allergensList.isEmpty ? "none" : allergensList.joined(separator: ", "))
        - Meals a day including snacks: \(ProfileManager.shared.user.frequency != nil ? "\(ProfileManager.shared.user.frequency!)" : "not important")
        - Birthday: \(ProfileManager.shared.user.birthday != nil ? "\(ProfileManager.shared.user.birthday!)" : "unknown age")
        - Height: \(ProfileManager.shared.user.height != nil ? "\(ProfileManager.shared.user.height!) meters" : "unknown height")
        - Weight: \(ProfileManager.shared.user.weight != nil ? "\(ProfileManager.shared.user.weight!) kilograms" : "unknown weight")
        - Body Fat Percentage: \(ProfileManager.shared.user.bodyFatPercentage != nil ? "\(ProfileManager.shared.user.bodyFatPercentage!)%" : "unknown body percentage")
        - Lean Body Mass: \(ProfileManager.shared.user.leanBodyMass != nil ? "\(ProfileManager.shared.user.leanBodyMass!) kilograms" : "unknown lean body mass")
        - Active Energy: \(ProfileManager.shared.user.activeEnergy != nil ? "\(ProfileManager.shared.user.activeEnergy!) kcal" : "unknown active energy")
        - Activity Level: \(ProfileManager.shared.user.activity != nil ? "\(ProfileManager.shared.user.activity!)" : "unknown activity")
        - Resting Energy: \(ProfileManager.shared.user.restingEnergy != nil ? "\(ProfileManager.shared.user.restingEnergy!) kcal" : "unknown resting energy aka basal metabolism")
        - Gender: \(ProfileManager.shared.user.gender != nil ? hkBiologicalSexToGenderString(ProfileManager.shared.user.gender!) : "unknown gender")
        - Purpose: \(ProfileManager.shared.user.currentPurpose != nil ? "\(ProfileManager.shared.user.currentPurpose!)" : "unknown purpose")
        """
    }
    
    static func createRecipePrompt(from meal: Meal) -> String {
        // Create a string representation of the meal's data
        let itemsString = meal.items.map { item in
            return """
                {
                    "item": "\(item.item)",
                    "quantity": "\(item.quantity)"
                }
                """
        }.joined(separator: ",\n")
        let nutrientsString = """
            {
                "kcal": \(meal.nutrients?.kcal ?? 0),
                "protein": \(meal.nutrients?.protein ?? 0),
                "carbohydrate": \(meal.nutrients?.carbohydrate ?? 0),
                "fat": \(meal.nutrients?.fat ?? 0)
            }
            """
        return """
            Create a personalized recipe based on the following meal information. Include 'name', 'totalNutrients', 'ingredients', and 'instructions' fields in the JSON response. Use this structure:
            {
                "name": "<String>",
                "totalNutrients": {
                    "kcal": <Int>,
                    "protein": <Int>,
                    "carbohydrate": <Int>,
                    "fat": <Int>
                },
                "ingredients": [
                    {"item": "<String>", "quantity": "<String>"}
                ],
                "instructions": "<String>"
            }
            Meal Information: {
                "name": "\(meal.name)",
                "totalNutrients": \(nutrientsString),
                "ingredients": [
                    \(itemsString)
                ]
            }
            """
    }

    static func createNewMealPrompt(from meal: Meal) -> String {
        // Convert meal items to a dictionary format
        let itemsArray = meal.items.map { item in
            return [
                "item": item.item,
                "quantity": item.quantity
            ]
        }

        // Nutrients data
        let nutrients: [String: Any] = [
            "kcal": meal.nutrients?.kcal ?? 0,
            "protein": meal.nutrients?.protein ?? 0,
            "carbohydrate": meal.nutrients?.carbohydrate ?? 0,
            "fat": meal.nutrients?.fat ?? 0
        ]
        
        // JSON structure for meal
        let mealData: [String: Any] = [
            "name": meal.name,
            "nutrients": nutrients,
            "items": itemsArray
        ]
        
        // Total Nutrients for the entire day (mocked for simplicity, can be dynamic if needed)
        let totalNutrients: [String: Any] = [
            "kcal": meal.nutrients?.kcal ?? 0,
            "protein": meal.nutrients?.protein ?? 0,
            "carbohydrate": meal.nutrients?.carbohydrate ?? 0,
            "fat": meal.nutrients?.fat ?? 0
        ]
        
        // Build the final JSON response
        let response: [String: Any] = [
            "totalNutrients": totalNutrients,
            "meals": [mealData]
        ]
        
        // Convert the response to a JSON string
        let jsonString: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: .prettyPrinted),
           let formattedJsonString = String(data: jsonData, encoding: .utf8) {
            jsonString = formattedJsonString
        } else {
            jsonString = "{}" // Return empty JSON if something goes wrong
        }

        // Create the full prompt with the meal data in JSON format
        return """
        Generate a distinct alternative to the meal provided below. Follow all rules precisely and use different ingredients to create a new meal that is nutritionally similar but diverse in taste and preparation. Avoid using the same primary ingredients as much as possible.

        **Rules**:
        1. **JSON Format**: The response must be a valid JSON object with the following structure:
        {
            "totalNutrients": {
                "kcal": INT,
                "protein": INT,
                "carbohydrate": INT,
                "fat": INT
            },
            "meals": [
                {
                    "name": STRING,
                    "nutrients": {
                        "kcal": INT,
                        "protein": INT,
                        "carbohydrate": INT,
                        "fat": INT
                    },
                    "items": [
                        {"item": STRING, "quantity": STRING},
                        ...
                    ]
                },
                ...
            ]
        }
        
        2. **Strict JSON Only**: Do not include any additional text, comments, or explanations outside of the JSON object.
        
        3. **Focus on Variety**:
            - Choose different ingredients or cuisine styles to ensure variety in taste and preparation.
            - Aim for a similar nutritional profile without repeating the original main ingredients.
        
        4. **New Meal Name and Ingredients**:
            - Name of the new meal will be Alternative "\(meal.name)".
            - Give new meal according to title. Do not give salmon or beef it is breakfast
            - Try to keep nutrients the same do not make significant changes
            - Only give meals in grams or pieces
            
        5. **Diet Preference**:
            - Diet Preference: \(ProfileManager.shared.user.dietPreference != nil ? "\(ProfileManager.shared.user.dietPreference!)" : "none")
            
        **Original Meal**:
        \(jsonString)
        """
    }
    
    static func hkBiologicalSexToGenderString(_ biologicalSex: HKBiologicalSex) -> String {
        switch biologicalSex {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        case .notSet:
            return "Not Set"
        @unknown default:
            return "Unknown"
        }
    }
}
