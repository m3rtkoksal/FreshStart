//
//  MealManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

class MealManager {
    static let shared = MealManager()
    private let selectedMealsKeyPrefix = "selectedMeals_"
    private let waterIntakeKey = "waterIntake"
    private let filledGlassesKey = "filledGlasses"
    private let lastResetKey = "lastResetDate"
    
    // MARK: - Meals Management
    
    // Save selected meals to UserDefaults
    func saveSelectedMeals(dietPlanId: String, selectedMeals: Set<Meal>) {
        let defaults = UserDefaults.standard
        
        // Convert the Set of Meals into Data for UserDefaults
        if let encodedMeals = try? JSONEncoder().encode(selectedMeals) {
            defaults.set(encodedMeals, forKey: "\(selectedMealsKeyPrefix)\(dietPlanId)")
        }
    }
    
    // Load selected meals from UserDefaults
    func loadSelectedMeals(dietPlanId: String) -> Set<Meal> {
        let defaults = UserDefaults.standard
        
        if let savedMealsData = defaults.data(forKey: "\(selectedMealsKeyPrefix)\(dietPlanId)"),
           let decodedMeals = try? JSONDecoder().decode(Set<Meal>.self, from: savedMealsData) {
            return decodedMeals
        }
        return [] // Return an empty set if nothing is found
    }
    
    // Clean all selected meals
    func cleanAllSelectedMeals() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        for key in dictionary.keys {
            if key.hasPrefix(selectedMealsKeyPrefix) {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    // MARK: - Water Tracking Management
    
    func saveWaterData(waterIntake: Int, filledGlasses: Int) {
        let defaults = UserDefaults.standard
        
        // Fetch current water entries
        var waterEntries = loadWaterEntries()
        
        // Create a new entry for today
        let newEntry = DailyWaterEntry(waterIntake: waterIntake, date: Date())
        
        // Add the new entry to the list of entries
        waterEntries.append(newEntry)
        
        // Store the updated list in UserDefaults
        if let encoded = try? JSONEncoder().encode(waterEntries) {
            defaults.set(encoded, forKey: "WaterEntries")
        }
        
        // Save the latest water intake and filled glasses
        defaults.set(waterIntake, forKey: waterIntakeKey)
        defaults.set(filledGlasses, forKey: filledGlassesKey)
    }
    
    // Load water entries from UserDefaults
    func loadWaterEntries() -> [DailyWaterEntry] {
        let defaults = UserDefaults.standard
        
        // Retrieve the saved data
        if let savedData = defaults.data(forKey: "WaterEntries"),
           let waterEntries = try? JSONDecoder().decode([DailyWaterEntry].self, from: savedData) {
            return waterEntries
        }
        
        return []
    }
    
    // Load filled glasses for the most recent day from UserDefaults
    func loadFilledGlasses() -> Int {
        let waterEntries = loadWaterEntries() // Load all water entries
        
        // Check if there are any water entries available
        guard let latestEntry = waterEntries.last else { return 0 }
        
        // Calculate the number of glasses based on the latest water intake
        return latestEntry.waterIntake / 250 // Assuming each glass is 250 ml
    }
    
    // Reset water tracking data by clearing daily entries from UserDefaults
    func resetWaterData() {
        let defaults = UserDefaults.standard
        
        // Remove the array of daily water entries
        defaults.removeObject(forKey: "WaterEntries")
        
        // Optionally reset the water intake and filled glasses as well
        defaults.removeObject(forKey: waterIntakeKey)
        defaults.removeObject(forKey: filledGlassesKey)
    }

    
    // MARK: - Daily Reset
    func checkAndCleanDaily() {
        let defaults = UserDefaults.standard
        let now = Date()
        
        // Get the last reset date
        if let lastResetDate = defaults.object(forKey: lastResetKey) as? Date {
            // Check if the last reset was more than 24 hours ago
            if now.timeIntervalSince(lastResetDate) > 86400 {
                cleanAllSelectedMeals()
                resetWaterData()  // Reset water data for today
                defaults.set(now, forKey: lastResetKey)  // Set the new reset time
            }
        } else {
            // If there's no record of the last reset, reset now
            cleanAllSelectedMeals()
            resetWaterData()  // Reset water data for today
            defaults.set(now, forKey: lastResetKey)  // Set the new reset time
        }
    }
}

struct DailyWaterEntry: Codable {
    var waterIntake: Int // in milliliters
    var date: Date
}
