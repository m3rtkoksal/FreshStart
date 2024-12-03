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
            return "No data available."
        }
        
        // Calculate the percentage difference
        let change = (oldestEntry - latestEntry) * 100  // Scaling to percentage
        let changeType = change > 0 ? "lost" : "gained"
        
        return "You have \(changeType) \(String(format: "%.2f", abs(change)))% of your body fat."
    }
    
    var leanBodyMassChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.leanBodyMass,
              let oldestEntry = healthDataEntries.last?.leanBodyMass else {
            return "No data available."
        }
        
        // Calculate the percentage difference
        let change = ((latestEntry - oldestEntry) / oldestEntry) * 100
        let changeType = change > 0 ? "gained" : "lost"
        
        return "You have \(changeType) \(String(format: "%.2f", abs(change)))% of your lean body mass."
    }

    var activeEnergyChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.activeEnergy,
              let oldestEntry = healthDataEntries.last?.activeEnergy else {
            return "No data available."
        }
        
        // Calculate the percentage difference
        let change = latestEntry - oldestEntry
        let changeType = change > 0 ? "gained" : "lost"
        
        return "You have \(changeType) \(String(format: "%.2f", abs(change))) kcal active energy."
    }
    
    var weightChangeDescription: String {
        guard let latestEntry = healthDataEntries.first?.weight,
              let oldestEntry = healthDataEntries.last?.weight else {
            return "No data available."
        }
        
        // Calculate the percentage difference
        let change = latestEntry - oldestEntry
        let changeType = change > 0 ? "gained" : "lost"
        
        return "You have \(changeType) \(String(format: "%.2f", abs(change))) kg."
    }

    func fetchChartSegments() {
        self.chartSegmentItems = [
            SegmentTitle(title: "Body Fat %"),
            SegmentTitle(title: "Lean Body Mass"),
            SegmentTitle(title: "Active Energy"),
            SegmentTitle(title: "Weight")
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

