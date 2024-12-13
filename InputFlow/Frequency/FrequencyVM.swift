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
        FrequencyItem(numberOfMeals: 7, subtitle: "frequency_7_meals_subtitle".localized(), icons: ["Meal1", "Meal2", "Meal3", "Meal4", "Meal5", "Meal6", "Meal7"]),
        FrequencyItem(numberOfMeals: 6, subtitle: "frequency_6_meals_subtitle".localized(), icons: ["Meal1", "Meal2", "Meal3", "Meal4", "Meal5", "Meal6"]),
        FrequencyItem(numberOfMeals: 5, subtitle: "frequency_5_meals_subtitle".localized(), icons: ["Meal1", "Meal2", "Meal3", "Meal4", "Meal5"]),
        FrequencyItem(numberOfMeals: 4, subtitle: "frequency_4_meals_subtitle".localized(), icons: ["Meal1", "Meal2", "Meal3", "Meal5"]),
        FrequencyItem(numberOfMeals: 3, subtitle: "frequency_3_meals_subtitle".localized(), icons: ["Meal1", "Meal3", "Meal5"]),
        FrequencyItem(numberOfMeals: 2, subtitle: "frequency_2_meals_subtitle".localized(), icons: ["Meal1", "Meal3"]),
    ]
}
