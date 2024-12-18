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
        let allergensList = ProfileManager.shared.user.allergens.map { $0.id ?? "Unknown Allergen" }
        return """
        \( "prompt_create".localized() )
        
        **Rules**:
        1. **JSON Format**:
              \( "prompt_rules_json_format".localized() )
        
        2. **Total Nutrients**:
              \( "prompt_rules_total_nutrients".localized() )
        
        3. **Meals**:
              \( "prompt_rules_meals".localized() )
        
        4. **Meal Units**:
              \( "prompt_rules_meal_units".localized() )
        
        5. **Strict JSON Only**:
              \( "prompt_rules_strict_json_only".localized() )
        
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
        - Gender: \(ProfileManager.shared.user.gender?.toLocalizedString() ?? "unknown gender")
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
            \( "prompt_create_recipe".localized() )
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
        \( "prompt_generate_alternative_meal".localized() )
        **\( "rules".localized() )**:
        1. **\( "json_format".localized() )**: \( "response_structure".localized() )
        
        2. **\( "strict_json_only".localized() )**: \( "no_extra_text".localized() )
        
        3. **\( "focus_on_variety".localized() )**:
            - \( "choose_different_ingredients".localized() )
            - \( "aim_for_similar_nutritional_profile".localized() )
        
        4. **\( "new_meal_name_and_ingredients".localized() )**:
            - \( "alternative_meal_name".localized() ) "\(meal.name)"
            - \( "do_not_give_salmon_or_beef_for_breakfast".localized() )
            - \( "keep_nutrients_same".localized() )
            - \( "provide_meals_in_grams_or_pieces".localized() )
        
        5. **\( "diet_preference".localized() )**:
            - \( "diet_preference_value".localized(ProfileManager.shared.user.dietPreference != nil ? "\(ProfileManager.shared.user.dietPreference!)" : "none") )
            
        **\( "original_meal".localized() )**:
        \(jsonString)
        """
    }
}
