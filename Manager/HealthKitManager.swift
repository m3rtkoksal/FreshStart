//
//  HealthKitManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import HealthKit
import FirebaseFirestore

class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    private var healthStore = HKHealthStore()
    private let db = Firestore.firestore()  // Add Firestore instance
    private var query: HKStatisticsCollectionQuery?
    @Published var isAuthorized = false
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)!,
            HKObjectType.quantityType(forIdentifier: .leanBodyMass)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        ]
        
        healthStore.requestAuthorization(toShare: [], read: readTypes) { (success, error) in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if let error = error {
                    AnalyticsHelper.log("Error requesting HealthKit authorization!",
                                        eventParameters: ["error":error.localizedDescription])
                }
                completion(success)
            }
        }
    }
    
    func hkBiologicalSexToGenderString(_ biologicalSex: HKBiologicalSex) -> String {
        switch biologicalSex {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        case .notSet:
            return "Not Set"
        @unknown default:
            return "Unknown"
        }
    }
    
    func calculateSteps(completion: @escaping (HKStatisticsCollection?) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let offset = -8
        let startDate = Calendar.current.date(byAdding: .day, value: offset, to: Date())!
        let anchorDate = Date.mondayAt12AM()
        let daily = DateComponents(day: 1)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)
        query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)
        
        query?.initialResultsHandler = { _, statisticsCollection, _ in
            completion(statisticsCollection)
        }
        
        healthStore.execute(query!)
    }
   
    func fetchYearlyData(userId: String, completion: @escaping (Double?, Double?, Double?, Double?, Double?, HKBiologicalSex?, Double?, String?, Double?, Double?, String?) -> Void) {
        guard isAuthorized else {
            completion(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil)
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        var activeEnergy: Double?
        var restingEnergy: Double?
        var bodyFatPercentage: Double?
        var leanBodyMass: Double?
        var weight: Double?
        var height: Double?
        var gender: HKBiologicalSex?
        var birthday: String?
        var heartRate: Double?
        var hrv: Double?
        var stressLevel: String?
        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -1, to: now)!
        
        func fetchData(for type: HKQuantityTypeIdentifier, unit: HKUnit, isDiscrete: Bool, completion: @escaping (Double?) -> Void) {
            let quantityType = HKQuantityType.quantityType(forIdentifier: type)!
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: [])
            
            let query: HKStatisticsQuery
            if isDiscrete {
                query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, error in
                    if let error = error {
                        AnalyticsHelper.log("Error fetching from HealthKit",
                                            eventParameters: ["error":error.localizedDescription, "type" : type.rawValue])
                        completion(nil)
                        return
                    }
                    
                    let quantity = result?.averageQuantity()
                    let value = quantity?.doubleValue(for: unit)
                    completion(value)
                }
            } else {
                query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                    if let error = error {
                        AnalyticsHelper.log("Error fetching from HealthKit",
                                            eventParameters: ["error":error.localizedDescription, "type" : type.rawValue])
                        completion(nil)
                        return
                    }
                    
                    let quantity = result?.sumQuantity()
                    let value = quantity?.doubleValue(for: unit)
                    completion(value)
                }
            }
            
            healthStore.execute(query)
        }
        
        dispatchGroup.enter()
        fetchData(for: .activeEnergyBurned, unit: .kilocalorie(), isDiscrete: false) { value in
            activeEnergy = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchData(for: .basalEnergyBurned, unit: .kilocalorie(), isDiscrete: false) { value in
            restingEnergy = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchData(for: .bodyFatPercentage, unit: .percent(), isDiscrete: true) { value in
            bodyFatPercentage = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchData(for: .leanBodyMass, unit: .gramUnit(with: .kilo), isDiscrete: true) { value in
            leanBodyMass = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchData(for: .bodyMass, unit: .gramUnit(with: .kilo), isDiscrete: true) { value in
            weight = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchData(for: .height, unit: .meter(), isDiscrete: true) { value in
            height = value
            if height == nil { // Fallback to the latest value if nil
                self.fetchMostRecentHeight { mostRecentHeight in
                    height = mostRecentHeight
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.enter()
        fetchGender { value in
            gender = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchDateOfBirth { dob in
            if let dob = dob {
                birthday = dob.getFormattedDate(format: "dd.MM.yyyy")
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchMostRecentWeight { value in
            weight = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchMostRecentHeartRate { value in
            heartRate = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        fetchMostRecentHRV { value in
            hrv = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        calculateStressLevel { value in
            stressLevel = value
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(activeEnergy, restingEnergy, bodyFatPercentage, leanBodyMass, weight, gender, height, birthday, heartRate, hrv, stressLevel)
        }
    }
    //MARK: Stress Level
    func calculateStressLevel(completion: @escaping (String?) -> Void) {
        fetchMostRecentHeartRate { heartRate in
            self.fetchMostRecentHRV { hrv in
                guard let hrv = hrv, let heartRate = heartRate else {
                    completion(nil)
                    return
                }
                
                let stressLevel: String
                // Example baselines for demonstration purposes
                let baselineHR = 75.0
                let baselineHRV = 40.0
                
                if hrv < baselineHRV * 0.5 && heartRate > baselineHR + 25 {
                    stressLevel = "severe_stress".localized()
                } else if hrv < baselineHRV * 0.7 && heartRate > baselineHR + 15 {
                    stressLevel = "high_stress".localized()
                } else if hrv < baselineHRV * 0.85 || heartRate > baselineHR + 5 {
                    stressLevel = "moderate_stress".localized()
                } else {
                    stressLevel = "low_stress".localized()
                }
                completion(stressLevel)
            }
        }
    }

    func fetchMostRecentHeartRate(completion: @escaping (Double?) -> Void) {
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                AnalyticsHelper.log("Error fetching most recent heart rate from HealthKit", eventParameters: ["error": error.localizedDescription])
                completion(nil)
                return
            }
            
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            completion(heartRate)
        }
        healthStore.execute(query)
    }
    
    func fetchMostRecentHRV(completion: @escaping (Double?) -> Void) {
        let hrvType = HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: hrvType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                AnalyticsHelper.log("Error fetching most recent HRV from HealthKit", eventParameters: ["error": error.localizedDescription])
                completion(nil)
                return
            }
            
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let hrv = sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            completion(hrv)
        }
        healthStore.execute(query)
    }

    func fetchGender(completion: @escaping (HKBiologicalSex?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil)
            return
        }
        
        do {
            let biologicalSex = try healthStore.biologicalSex().biologicalSex
            completion(biologicalSex)
        } catch {
            AnalyticsHelper.log("Error fetching gender from HealthKit", eventParameters: ["error" : error.localizedDescription])
            completion(nil)
        }
    }
    
    func fetchDateOfBirth(completion: @escaping (Date?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(nil)
            return
        }
        
        do {
            let dateOfBirth = try healthStore.dateOfBirthComponents().date
            completion(dateOfBirth)
        } catch {
            AnalyticsHelper.log("Error fetching date of birth from HealthKit", eventParameters: ["error" : error.localizedDescription])
            completion(nil)
        }
    }
    
    func fetchMostRecentWeight(completion: @escaping (Double?) -> Void) {
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                AnalyticsHelper.log("Error fetching most recent weight from HealthKit", eventParameters: ["error" : error.localizedDescription])
                completion(nil)
                return
            }
            
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            
            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weight)
        }
        healthStore.execute(query)
    }
    
    func fetchMostRecentHeight(completion: @escaping (Double?) -> Void) {
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let error = error {
                AnalyticsHelper.log("Error fetching most recent height from HealthKit", eventParameters: ["error" : error.localizedDescription])
                completion(nil)
                return
            }
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil)
                return
            }
            let height = sample.quantity.doubleValue(for: HKUnit.meter())
            completion(height)
        }
        healthStore.execute(query)
    }
    
    func saveHealthDataToFirestore(
        userId: String,
        activeEnergy: Double?,
        restingEnergy: Double?,
        bodyFatPercentage: Double?,
        leanBodyMass: Double?,
        weight: Double?,
        gender: HKBiologicalSex?,
        height: Double?,
        birthday: String?,
        heartRate: Double?,
        hrv: Double?,
        stressLevel: String?,
        completion: @escaping () -> Void
    ) {
        let healthDataEntry: [String: Any] = [
            "userId": userId,
            "activeEnergyBurned": activeEnergy as Any,
            "restingEnergyBurned": restingEnergy as Any,
            "bodyFatPercentage": bodyFatPercentage as Any,
            "leanBodyMass": leanBodyMass as Any,
            "weight": weight as Any,
            "height": height as Any,
            "gender": hkBiologicalSexToGenderString(gender ?? .notSet),
            "birthday": birthday as Any,
            "heartrate": heartRate as Any,
            "hrv": hrv as Any,
            "stressLevel": stressLevel as Any,
            "timestamp": Timestamp(date: Date())
        ]
        
        let db = Firestore.firestore()
        let healthDataDocId = UUID().uuidString
        db.collection("healthData").document(healthDataDocId).setData(healthDataEntry) { error in
            if let error = error {
                AnalyticsHelper.log("Error saving health data to Firestore", eventParameters: ["error" : error.localizedDescription])
            } else {
                AnalyticsHelper.log("Health data entry successfully saved to Firestore.", eventParameters: [:])
                completion()
            }
        }
    }
}

