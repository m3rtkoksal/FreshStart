//
//  AllergensVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class AllergensVM: BaseViewModel {
    @Published var fetchedAllergens: [Allergen] = [
        Allergen(id: "Apple", severityLevel: 2, type: "fruit"),
        Allergen(id: "Buckwheat", severityLevel: 2, type: "grain"),
        Allergen(id: "Celery", severityLevel: 3, type: "vegetable"),
        Allergen(id: "Corn", severityLevel: 2, type: "grain"),
        Allergen(id: "Egg", severityLevel: 3, type: "dairy"),
        Allergen(id: "Lupin", severityLevel: 2, type: "legume"),
        Allergen(id: "Milk", severityLevel: 4, type: "dairy"),
        Allergen(id: "Mollusk", severityLevel: 4, type: "seafood"),
        Allergen(id: "Mustard", severityLevel: 3, type: "spice"),
        Allergen(id: "Peach", severityLevel: 2, type: "fruit"),
        Allergen(id: "Peanut", severityLevel: 5, type: "nut"),
        Allergen(id: "Poppy Seed", severityLevel: 2, type: "seed"),
        Allergen(id: "Sesame", severityLevel: 3, type: "seed"),
        Allergen(id: "Shellfish", severityLevel: 5, type: "seafood"),
        Allergen(id: "Soy", severityLevel: 3, type: "legume"),
        Allergen(id: "Sulphite", severityLevel: 3, type: "additive"),
        Allergen(id: "Sunflower Seed", severityLevel: 2, type: "seed"),
        Allergen(id: "Tree Nut", severityLevel: 5, type: "nut"),
        Allergen(id: "Wheat", severityLevel: 3, type: "grain")
    ]
    @Published var goToLoadingView = false
    
    func saveHealthDataToFirestore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            
            HealthKitManager.shared.saveHealthDataToFirestore(
                userId: userId,
                activeEnergy: ProfileManager.shared.user.activeEnergy,
                restingEnergy: ProfileManager.shared.user.restingEnergy,
                bodyFatPercentage: ProfileManager.shared.user.bodyFatPercentage,
                leanBodyMass: ProfileManager.shared.user.leanBodyMass,
                weight: ProfileManager.shared.user.weight,
                gender: ProfileManager.shared.user.gender,
                height: ProfileManager.shared.user.height,
                birthday: ProfileManager.shared.user.birthday,
                heartRate: ProfileManager.shared.user.heartRate,
                hrv: ProfileManager.shared.user.hrv,
                stressLevel: ProfileManager.shared.user.stressLevel
            ) {
                print("Health data saved successfully.")
            }
        }
    }
}
