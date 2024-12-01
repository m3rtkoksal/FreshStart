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
    @Published var fetchedAllergens: [Allergen] = []
    @Published var goToLoadingView = false

    func fetchAllergens() {
        let db = Firestore.firestore()
        db.collection("allergens").getDocuments { (querySnapshot, error) in
            // Handle errors
            if error != nil {
                return
            }
            guard let documents = querySnapshot?.documents else {
                return
            }
            self.fetchedAllergens.removeAll()
            for document in documents {
                do {
                    var allergen = try document.data(as: Allergen.self)
                    allergen.id = document.documentID
                    self.fetchedAllergens.append(allergen)
                } catch {
                }
            }
            DispatchQueue.main.async {
                self.fetchedAllergens = self.fetchedAllergens
            }
        }
    }
    
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
