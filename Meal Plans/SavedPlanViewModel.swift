//
//  SavedPlanViewModel.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SavedPlanViewModel: BaseViewModel {
    @Published var goToCreateNewPlan = false
    @Published var dietPlans: [DietPlan] = []
    @Published var createdPlanCount: Int = 0
    @Published var maxPlanCount: Int = 0
    @Published var showDietPlanPreview: Bool = false
    @Published var showChangeAlert: Bool = false
    @Published var changeAlertMessage: String = ""
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var activeAlert: AlertType?
   
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
    
    func saveDefaultPlanToFirestore(planId: String) {
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

    private func checkHealthKitAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.healthKitManager.isAuthorized {
                self.activeAlert = .authorizationRequired
            }
        }
    }
    
    func fetchDietPlans() {
        self.showIndicator = true
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("dietPlans")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                var fetchedDietPlans: [DietPlan] = []
                for document in querySnapshot?.documents ?? [] {
                    do {
                        var dietPlan = try document.data(as: DietPlan.self)
                        dietPlan.id = document.documentID
                        if let createdAtTimestamp = document["createdAt"] as? Timestamp {
                            dietPlan.createdAt = createdAtTimestamp.dateValue()
                        } else {
                            dietPlan.createdAt = Date()
                        }
                        dietPlan.userId = document["userId"] as? String ?? ""
                        dietPlan.purpose = document["purpose"] as? String ?? ""
                        dietPlan.dietPreference = document["dietPreference"] as? String ?? ""
                        
                        if !fetchedDietPlans.contains(where: { $0.id == dietPlan.id }) {
                            if dietPlan.meals.count > 0 {
                                fetchedDietPlans.append(dietPlan)
                            }
                        }
                    } catch {
                        AnalyticsHelper.log("Error decoding diet plan", eventParameters: ["error" : error.localizedDescription])
                    }
                }
                
                fetchedDietPlans.sort {
                    guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                        return false
                    }
                    return date1 > date2
                }
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    ProfileManager.shared.setUserDietPlans(fetchedDietPlans)
                    self.dietPlans = fetchedDietPlans
                    self.createdPlanCount = fetchedDietPlans.count
                    self.showIndicator = false
                }
            }
    }
    
    func saveHealthDataToUserInputModel(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Fetch yearly data from HealthKit
        healthKitManager.fetchYearlyData(userId: userId) { activeEnergyData, restingEnergyData, bodyFatPercentageData, leanBodyMassData, weightData, genderData, heightData, birthdayData, heartRateData, hrvData, stressLevelData in
            ProfileManager.shared.setCustomerId(id: userId)
            let daysInYear = 365.0
            let dailyActiveEnergy = (activeEnergyData ?? 0.0) / daysInYear
            let dailyRestingEnergy = (restingEnergyData ?? 0.0) / daysInYear
            // Update user input model
            ProfileManager.shared.setUserActiveEnegry(dailyActiveEnergy)
            ProfileManager.shared.setUserRestingEnegry(dailyRestingEnergy)
            ProfileManager.shared.setUserBodyFatPercentage(bodyFatPercentageData ?? 0)
            ProfileManager.shared.setUserLeanBodyMass(leanBodyMassData ?? 0)
            ProfileManager.shared.setUserWeight(weightData ?? 0)
            ProfileManager.shared.setUserHeight(heightData ?? 0)
            ProfileManager.shared.setUserHeartRate(heartRateData ?? 0)
            ProfileManager.shared.setUserHRV(hrvData ?? 0)
            ProfileManager.shared.setUserStressLevel(stressLevelData ?? "")
            if let gender = genderData {
                ProfileManager.shared.setUserGender(gender)
            }
            completion()
        }
    }
    
    func fetchMaxPlanCountFromFirestore() {
        self.showIndicator = true
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let error = error {
                return
            }
            
            guard let document = document, document.exists,
                  let maxPlanCount = document.get("maxPlanCount") as? Int else {
                return
            }
            self.maxPlanCount = maxPlanCount
            self.showIndicator = false
        }
    }
}
