//
//  HealthData.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import HealthKit

struct HealthData: Identifiable, Codable {
    var id: String?
    var createdAt: Date?
    var userId: String
    var username: String?
    var activeEnergy: Double?
    var restingEnergy: Double?
    var bodyFatPercentage: Double?
    var leanBodyMass: Double?
    var weight: Double?
    var height: Double?
    var gender: HKBiologicalSex?
    var birthday: String?
    var activity: String?
    var heartRate: Double?
    var hrv: Double?
    var stressLevel: String?
    
    // Conformance to Decodable and Encodable
    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case userId
        case username
        case activeEnergyBurned
        case restingEnergyBurned
        case bodyFatPercentage
        case leanBodyMass
        case weight
        case height
        case gender
        case birthday
        case activity
        case heartRate
        case hrv
        case stressLevel
    }

    // Custom Decodable initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .timestamp)
        userId = try container.decode(String.self, forKey: .userId)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        activeEnergy = try container.decodeIfPresent(Double.self, forKey: .activeEnergyBurned)
        restingEnergy = try container.decodeIfPresent(Double.self, forKey: .restingEnergyBurned)
        bodyFatPercentage = try container.decodeIfPresent(Double.self, forKey: .bodyFatPercentage)
        leanBodyMass = try container.decodeIfPresent(Double.self, forKey: .leanBodyMass)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        height = try container.decodeIfPresent(Double.self, forKey: .height)
        
        // Decoding the gender - using the hkBiologicalSexFromString method
        let genderString = try container.decodeIfPresent(String.self, forKey: .gender)
        gender = genderString.flatMap { hkBiologicalSexFromString($0) }
        
        birthday = try container.decodeIfPresent(String.self, forKey: .birthday)
        activity = try container.decodeIfPresent(String.self, forKey: .activity)
        heartRate = try container.decodeIfPresent(Double.self, forKey: .heartRate)
        hrv = try container.decodeIfPresent(Double.self, forKey: .hrv)
        stressLevel = try container.decodeIfPresent(String.self, forKey: .stressLevel)
    }
    
    // Custom Encodable method to handle encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(createdAt, forKey: .timestamp)
        try container.encode(userId, forKey: .userId)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(activeEnergy, forKey: .activeEnergyBurned)
        try container.encodeIfPresent(restingEnergy, forKey: .restingEnergyBurned)
        try container.encodeIfPresent(bodyFatPercentage, forKey: .bodyFatPercentage)
        try container.encodeIfPresent(leanBodyMass, forKey: .leanBodyMass)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(height, forKey: .height)
        
        // Encoding the gender - using the hkBiologicalSexToString method
        if let gender = gender {
            let genderString = hkBiologicalSexToString(gender)
            try container.encode(genderString, forKey: .gender)
        }
        
        try container.encodeIfPresent(birthday, forKey: .birthday)
        try container.encodeIfPresent(activity, forKey: .activity)
        try container.encodeIfPresent(stressLevel, forKey: .stressLevel)
        try container.encodeIfPresent(heartRate, forKey: .heartRate)
        try container.encodeIfPresent(hrv, forKey: .hrv)
    }

    // Existing function to map gender string to HKBiologicalSex enum
    func hkBiologicalSexFromString(_ value: String) -> HKBiologicalSex? {
        switch value.lowercased() {
        case "male": return .male
        case "female": return .female
        case "other": return .other
        case "not set": return .notSet
        default: return nil
        }
    }

    // Existing function to map HKBiologicalSex enum to string
    func hkBiologicalSexToString(_ biologicalSex: HKBiologicalSex) -> String {
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
}
