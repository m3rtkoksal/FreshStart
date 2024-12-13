//
//  OpenAIManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import HealthKit
import FirebaseFirestore
import FirebaseAuth

class OpenAIManager: ObservableObject {
    static let shared = OpenAIManager()
    private let db = Firestore.firestore()
    @Published var showAlert = false
    var alertMessage = ""
    
    func generatePrompt(completion: @escaping (DietPlan?) -> Void) {
        let prompt = PromptCreationHelper.createPrompt()
        print(prompt)
        
        guard let request = OpenAIRequestHelper.prepareOpenAIRequest(prompt: prompt) else {
            completion(nil)
            return
        }
        
        NetworkHelper.shared.executeRequest(request) { responseText in
            DispatchQueue.main.async {
                if let responseText = responseText, let responseData = responseText.data(using: .utf8) {
                    print("Raw Response: \(responseText)")
                    do {
                        let dietPlan = try JSONDecoder().decode(DietPlan.self, from: responseData)
                        completion(dietPlan)
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        completion(nil)
                    }
                } else {
                    self.showAlert = true
                    self.alertMessage = "failed_to_fetch_response".localized()
                    completion(nil)
                }
            }
        }
    }
    
    func generateRecipePrompt(meal: Meal, completion: @escaping (Recipe?) -> Void) {
        let prompt = PromptCreationHelper.createRecipePrompt(from: meal)
        print(prompt)
        
        // Prepare and execute the request
        guard let request = OpenAIRequestHelper.prepareOpenAIRequest(prompt: prompt) else {
            completion(nil)
            return
        }
        
        NetworkHelper.shared.executeRequest(request) { responseText in
            DispatchQueue.main.async {
                guard let responseText = responseText, !responseText.isEmpty else {
                    self.showAlert = true
                    self.alertMessage = "failed_to_fetch_response".localized()
                    completion(nil)
                    return
                }
                
                // Print the raw response for debugging
                print("Response Text: \(responseText)")
                
                // Attempt to decode the response into a Recipe object
                if let recipeData = responseText.data(using: .utf8) {
                    do {
                        let recipe = try JSONDecoder().decode(Recipe.self, from: recipeData)
                        completion(recipe) // Return the generated Recipe
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        self.showAlert = true
                        self.alertMessage = "failed_to_decode_recipe".localized()
                        completion(nil)
                    }
                } else {
                    self.showAlert = true
                    self.alertMessage = "failed_to_convert_response".localized()
                    completion(nil)
                }
            }
        }
    }
    
    func generateNewMealPrompt(meal: Meal, completion: @escaping (Meal?) -> Void) {
        let prompt = PromptCreationHelper.createNewMealPrompt(from: meal)
        print(prompt)
        
        // Prepare and execute the request
        guard let request = OpenAIRequestHelper.prepareOpenAIRequest(prompt: prompt) else {
            completion(nil)
            return
        }
        
        NetworkHelper.shared.executeRequest(request) { responseText in
            DispatchQueue.main.async {
                if let responseText = responseText {
                    print(responseText)
                    if let mealData = responseText.data(using: .utf8) {
                        do {
                            // Decode the response into MealResponse
                            let mealResponse = try JSONDecoder().decode(MealResponse.self, from: mealData)
                            
                            // Extract the first meal (or any specific meal you're targeting)
                            if let firstMeal = mealResponse.meals.first {
                                print("New Meal: \(firstMeal)")
                                completion(firstMeal)
                            } else {
                                print("No meals found in response")
                                completion(nil)
                            }
                        } catch {
                            print("Failed to decode JSON: \(error)")
                            self.showAlert = true
                            self.alertMessage = "failed_to_parse_meal".localized()
                            completion(nil)
                        }
                    } else {
                        print("Failed to convert responseText to Data")
                        self.showAlert = true
                        self.alertMessage = "failed_to_convert_response".localized()
                        completion(nil)
                    }
                }
            }
        }
    }
}

struct OpenAIResponseHandler {
    func decodeJson(jsonString: String) -> OpenAIResponse? {
        let json = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(OpenAIResponse.self, from: json)
            return response
        } catch {
            print("Error decoding OpenAI API response: \(error)")
            return nil
        }
    }
}

struct OpenAIResponse: Codable {
    var choices: [Choice]
}

struct Choice: Codable {
    var message: Message
}

struct Message: Codable {
    var content: String
}

