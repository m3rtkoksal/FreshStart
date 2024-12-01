//
//  WatchConnector.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import WatchConnectivity
import HealthKit
import SwiftUI

class WatchConnector: NSObject, WCSessionDelegate, ObservableObject {

    var session: WCSession
    let healthStore = HKHealthStore()
    @State private var water: Double = 0
    @State private var currentIntake: Double = 0
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        if session.isReachable {
            sendWaterIntakeToWatch()
        }
    }

    func sendWaterIntakeToWatch() {
        fetchDailyWaterIntake { totalWaterIntake, error in
            if let error = error {
                print("Error fetching water intake: \(error.localizedDescription)")
            } else if let totalWaterIntake = totalWaterIntake {
                let waterData: [String: Any] = ["currentWaterIntake": totalWaterIntake]
                WCSession.default.sendMessage(waterData, replyHandler: nil) { error in
                    print("Error sending water intake: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        self.water = message["water"] as? Double ?? 0
        self.logWater(amount: self.water)
    }
    func logWater(amount: Double) {
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amount)
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: Date(), end: Date())
        // Save water to HealthKit
        healthStore.save(sample) { (success, error) in
            if success {
                self.currentIntake += amount
            } else if let error = error {
                print("Error saving water: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchWaterIntakeForToday() {
        fetchDailyWaterIntake { totalWaterIntake, error in
            if let error = error {
                print("Error fetching water intake: \(error.localizedDescription)")
            } else if let totalWaterIntake = totalWaterIntake {
                DispatchQueue.main.async {
                    self.currentIntake = totalWaterIntake
                }
            }
        }
    }
    
    func fetchDailyWaterIntake(completion: @escaping (Double?, Error?) -> Void) {
        // Ensure HealthKit is available
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil, NSError(domain: "HealthKit not available", code: 1, userInfo: nil))
            return
        }
        
        // Define the water intake data type
        guard let waterType = HKObjectType.quantityType(forIdentifier: .dietaryWater) else {
            completion(nil, NSError(domain: "Invalid HealthKit type", code: 2, userInfo: nil))
            return
        }
        
        // Create a date range for today
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Create a predicate to filter today's data
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        // Create a statistics query to sum the water intake
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Get the sum of water intake
            let totalWaterIntake = result?.sumQuantity()?.doubleValue(for: .literUnit(with: .milli)) ?? 0
            completion(totalWaterIntake, nil)
        }
        
        // Execute the query
        HKHealthStore().execute(query)
    }
    
}
