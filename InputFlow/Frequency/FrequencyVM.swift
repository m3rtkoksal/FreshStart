//
//  FrequencyVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

class FrequencyVM: BaseViewModel {
    @Published var goToAllergensView = false
    @Published var frequencyItems: [FrequencyItem] = [
        FrequencyItem(numberOfMeals: 7, subtitle: "Breakfast, Lunch, Dinner and 4 Snacks",icons: ["Meal1", "Meal2", "Meal3", "Meal4", "Meal5", "Meal6", "Meal7"]),
        FrequencyItem(numberOfMeals: 6, subtitle: "Breakfast, Lunch, Dinner and 3 Snacks", icons: ["Meal1", "Meal2", "Meal3", "Meal4", "Meal5", "Meal6"]),
        FrequencyItem(numberOfMeals: 5, subtitle: "Breakfast, Lunch, Dinner and 2 Snacks", icons: ["Meal1", "Meal2", "Meal3", "Meal4", "Meal5"]),
        FrequencyItem(numberOfMeals: 4, subtitle: "Breakfast, Lunch, Dinner and 1 Snack", icons: ["Meal1", "Meal2", "Meal3", "Meal5"]),
        FrequencyItem(numberOfMeals: 3, subtitle: "Breakfast, Lunch and Dinner", icons: ["Meal1", "Meal3", "Meal5"]),
        FrequencyItem(numberOfMeals: 2, subtitle: "Breakfast and Lunch or Dinner", icons: ["Meal1", "Meal3"]),
    ]
}
