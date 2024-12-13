//
//  HealthChartType.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import FirebaseAuth
import SwiftUI
import FirebaseFirestore

enum HealthChartType: Int, CaseIterable {
    case bodyFat
    case leanBodyMass
    case activeEnergy
    case weight
}

class HealthDataChartVM: BaseViewModel {
    @Published var healthDataEntries: [HealthData] = []
    @Published var chartSegmentItems: [SegmentTitle] = []
    
    var bodyFatChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.bodyFatPercentage,
              let oldestEntry = healthDataEntries.last?.bodyFatPercentage else {
            return "no_data_available".localized()
        }
        
        // Calculate the percentage difference
        let change = (oldestEntry - latestEntry) * 100  // Scaling to percentage
        let changeType = change > 0 ? "lost".localized() : "gained".localized()
        
        return "\("body_fat_change_message".localized()) \(changeType) \(String(format: "%.2f", abs(change)))% \("of_your_body_fat".localized())"
    }
    
    var leanBodyMassChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.leanBodyMass,
              let oldestEntry = healthDataEntries.last?.leanBodyMass else {
            return "no_data_available".localized()
        }
        
        // Calculate the percentage difference
        let change = ((latestEntry - oldestEntry) / oldestEntry) * 100
        let changeType = change > 0 ? "gained".localized() : "lost".localized()
        
        return "\("lean_body_mass_change_message".localized()) \(changeType) \(String(format: "%.2f", abs(change)))% \("of_your_lean_body_mass".localized())"
    }

    var activeEnergyChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.activeEnergy,
              let oldestEntry = healthDataEntries.last?.activeEnergy else {
            return "no_data_available".localized()
        }
        
        // Calculate the percentage difference
        let change = latestEntry - oldestEntry
        let changeType = change > 0 ? "gained".localized() : "lost".localized()
        
        return "\("active_energy_change_message".localized()) \(changeType) \(String(format: "%.2f", abs(change))) \("kcal_active_energy".localized())"
    }
    
    var weightChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.weight,
              let oldestEntry = healthDataEntries.last?.weight else {
            return "no_data_available".localized()
        }
        
        // Calculate the percentage difference
        let change = latestEntry - oldestEntry
        let changeType = change > 0 ? "gained".localized() : "lost".localized()
        
        return "\("change_message".localized()) \(changeType) \(String(format: "%.2f", abs(change))) \("kg_unit".localized())"
    }

    func fetchChartSegments() {
        self.chartSegmentItems = [
            SegmentTitle(title: "body_fat_percentage".localized()),
            SegmentTitle(title: "lean_body_mass".localized()),
            SegmentTitle(title: "active_energy".localized()),
            SegmentTitle(title: "weight".localized())
        ]
    }
    
    func description(for type: HealthChartType) -> String {
        switch type {
        case .bodyFat:
            return bodyFatChangeDescription
        case .leanBodyMass:
            return leanBodyMassChangeDescription
        case .activeEnergy:
            return activeEnergyChangeDescription
        case .weight:
            return weightChangeDescription
        }
    }
    
    func fetchHealthDataEntries() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        self.showIndicator = true
        let db = Firestore.firestore()
        db.collection("healthData")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                var fetchedHealthData: [HealthData] = []
                for document in querySnapshot?.documents ?? [] {
                    do {
                        var healtData = try document.data(as: HealthData.self)
                        healtData.id = document.documentID
                        if !fetchedHealthData.contains(where: {$0.id == healtData.id}) {
                            fetchedHealthData.append(healtData)
                            fetchedHealthData.sort {
                                guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                                    return $0.createdAt != nil
                                }
                                return date1 < date2
                            }
                        }
                    }
                    catch {
                        print("Error decoding health data: \(error.localizedDescription)")
                    }
                }
                DispatchQueue.main.async {
                    self.healthDataEntries = fetchedHealthData
                    self.showIndicator = false
                }
            }
    }
}

