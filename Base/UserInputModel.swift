//
//  UserInputModel.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Combine
import HealthKit
import FirebaseCore
import FirebaseFirestore

class UserInputModel: ObservableObject {
    @Published var userId: String?
    @Published var firstName: String?
    @Published var lastName: String?
    @Published var userName: String?
    @Published var email: String?
    @Published var activeEnergy: Double?
    @Published var restingEnergy: Double?
    @Published var bodyFatPercentage: Double?
    @Published var leanBodyMass: Double?
    @Published var weight: Double?
    @Published var height: Double?
    @Published var gender: HKBiologicalSex?
    @Published var birthday: String?
    @Published var dietPreference: String?
    @Published var activity: String?
    @Published var steps: Int?
    @Published var currentPurpose: String?
    @Published var frequency: Int?
    @Published var dietPlanCount: Int?
    @Published var defaultDietPlan: DietPlan?
    @Published var allergens: [Allergen] = []
    @Published var subscriptionEndDate: Date = Date()
    @Published var isPremium: Bool?
    @Published var dailyLoginCount: Int?
    @Published var userDailyLoginCountList: [UserRankList] = []
    @Published var userBodyFatPercentageList: [UserRankList] = []
    @Published var userLeanBodyMassList: [UserRankList] = []
    @Published var defaultDietPlanId: String?
    //MARK: Stress Level
    @Published var hrv: Double?
    @Published var stressLevel: String?
    @Published var heartRate: Double?
}

struct DietPlan: Codable, Equatable, Identifiable {
    var id: String?
    var createdAt: Date?
    var totalNutrients: TotalNutrients?
    var meals: [Meal]
    var userId: String?
    var purpose: String?
    var dietPreference: String?
    
    init(
        id: String? = nil,
        createdAt: Date? = nil,
        totalNutrients: TotalNutrients = TotalNutrients(kcal: 0, protein: 0, carbohydrate: 0, fat: 0),
        meals: [Meal] = [],
        userId: String? = nil,
        purpose: String? = nil,
        dietPreference: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.totalNutrients = totalNutrients
        self.meals = meals
        self.userId = userId
        self.purpose = purpose
        self.dietPreference = dietPreference
    }

    static func ==(lhs: DietPlan, rhs: DietPlan) -> Bool {
        return lhs.id == rhs.id &&
        lhs.createdAt == rhs.createdAt &&
        lhs.totalNutrients == rhs.totalNutrients &&
        lhs.meals == rhs.meals &&
        lhs.userId == rhs.userId &&
        lhs.purpose == rhs.purpose &&
        lhs.dietPreference == rhs.dietPreference
    }
}

struct MealResponse: Codable {
    var totalNutrients: TotalNutrients
    var meals: [Meal]
}

struct Meal: Codable, Identifiable, Equatable, Hashable {
    var id: String? = UUID().uuidString
    var name: String
    var nutrients: TotalNutrients?
    var items: [Item]
    
    static func ==(lhs: Meal, rhs: Meal) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.nutrients == rhs.nutrients && lhs.items == rhs.items
    }
}

struct Item: Codable, Equatable, Hashable {
    var item: String
    var quantity: String
}

struct Recipe: Codable, Equatable, Identifiable {
    var id: String?
    var name: String
    var ingredients: [Ingredient]
    var instructions: String
    var totalNutrients: TotalNutrients?

    // Custom initializer with defaults for optional values
    init(
        id: String? = nil,
        name: String = "",
        ingredients: [Ingredient] = [],
        instructions: String = "",
        totalNutrients: TotalNutrients? = nil
    ) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.instructions = instructions
        self.totalNutrients = totalNutrients
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, ingredients, instructions, totalNutrients
    }
}

struct Ingredient: Codable, Equatable {
    var item: String
    var quantity: String
}

struct TotalNutrients: Codable, Equatable, Hashable {
    var kcal: Int
    var protein: Int
    var carbohydrate: Int
    var fat: Int
    
    init(from data: [String: Any]) {
        self.kcal = data["kcal"] as? Int ?? 0
        self.protein = data["protein"] as? Int ?? 0
        self.carbohydrate = data["carbohydrate"] as? Int ?? 0
        self.fat = data["fat"] as? Int ?? 0
    }
    init(kcal: Int = 0, protein: Int = 0, carbohydrate: Int = 0, fat: Int = 0) {
        self.kcal = kcal
        self.protein = protein
        self.carbohydrate = carbohydrate
        self.fat = fat
    }
    
    static func - (lhs: TotalNutrients, rhs: TotalNutrients) -> TotalNutrients {
        return TotalNutrients(
            kcal: max(0, lhs.kcal - rhs.kcal),
            protein: max(0, lhs.protein - rhs.protein),
            carbohydrate: max(0, lhs.carbohydrate - rhs.carbohydrate),
            fat: max(0, lhs.fat - rhs.fat)
        )
    }
    
    static func calculateRemaining(initial: TotalNutrients, selectedMeals: Set<Meal>) -> TotalNutrients {
        let selectedNutrients = selectedMeals.reduce(TotalNutrients()) { total, meal in
            guard let nutrients = meal.nutrients else { return total }
            return TotalNutrients(
                kcal: total.kcal + nutrients.kcal,
                protein: total.protein + nutrients.protein,
                carbohydrate: total.carbohydrate + nutrients.carbohydrate,
                fat: total.fat + nutrients.fat
            )
        }
        return initial - selectedNutrients
    }
}

struct Allergen: Identifiable, Codable {
    var id: String?
    var name: String?
    var severityLevel: Int?
    var type: String?
}

struct UserRankList: Identifiable, Codable {
    var id: String?
    var username: String?
    var rank: Int?
    var value: Double?
}
