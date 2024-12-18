//
//  ProfileManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Combine
import HealthKit
import FirebaseCore

final class ProfileManager: ObservableObject {
    
    static let shared = ProfileManager()
    
    @Published private(set) var user: UserInputModel
    
    private var _hasGeneratedDietPlan: Bool = false
    
    var userPublisher: AnyPublisher<UserInputModel, Never> {
        $user.eraseToAnyPublisher()
    }
    
    private init() {
        user = UserInputModel()
    }
    
    func setCustomerId(id: String) {
        self.user.userId = id
        AnalyticsHelper.setUserId(userId: id)
    }
    
    func setLanguage(_ language: String) {
        self.user.language = language
    }
    
    func setUserEmail(_ email: String) {
        self.user.email = email
    }
    
    func setUserFirstName(_ firstName: String) {
        self.user.firstName = firstName
    }
    
    func setUserSurname(_ lastName: String) {
        self.user.lastName = lastName
    }
    
    func setUserName(_ username: String) {
        self.user.userName = username
    }
    
    func setUserHealthData(from healthData: HealthData) {
        self.user.activeEnergy = healthData.activeEnergy
        self.user.restingEnergy = healthData.restingEnergy
        self.user.bodyFatPercentage = healthData.bodyFatPercentage
        self.user.leanBodyMass = healthData.leanBodyMass
        self.user.weight = healthData.weight
        self.user.height = healthData.height
        self.user.gender = healthData.gender
        self.user.birthday = healthData.birthday
        self.user.activity = healthData.activity
    }
    
    func setUserActiveEnegry(_ activeEnergy: Double) {
        self.user.activeEnergy = activeEnergy
    }
    
    func setUserRestingEnegry(_ restingEnergy: Double) {
        self.user.restingEnergy = restingEnergy
    }
    
    func setUserBodyFatPercentage(_ bodyFatPercentage: Double) {
        self.user.bodyFatPercentage = bodyFatPercentage
    }
    
    func setUserLeanBodyMass(_ leanBodyMass: Double) {
        self.user.leanBodyMass = leanBodyMass
    }
    
    func setUserWeight(_ weight: Double) {
        self.user.weight = weight
    }
    
    func setUserHeight(_ height: Double) {
        self.user.height = height
    }
    
    func setUserGender(_ gender: HKBiologicalSex) {
        self.user.gender = gender
    }
    
    func setUserBirthday(_ birthday: String) {
        self.user.birthday = birthday
    }
    
    func setUserDietPreference(_ preference: String) {
        self.user.dietPreference = preference
    }
    
    func setUserActivity(_ activity: String) {
        self.user.activity = activity
    }
    
    func setUserSteps(_ steps: Int) {
        self.user.steps = steps
    }
    
    func setUserCurrentPurpose(_ currentPurpose: String) {
        self.user.currentPurpose = currentPurpose
    }
    
    func setUserMealFrequency(_ frequency: Int) {
        self.user.frequency = frequency
    }
    
    func setUserDietPlanCount(_ count: Int) {
        self.user.dietPlanCount = count
    }
    
    func incrementDietPlanCount() {
        if let currentCount = self.user.dietPlanCount {
            self.user.dietPlanCount = currentCount + 1
        } else {
            self.user.dietPlanCount = 1
        }
        setUserDietPlanCount(self.user.dietPlanCount ?? 0)
    }
    
    func decrementDietPlanCount() {
        if let currentCount = self.user.dietPlanCount {
            self.user.dietPlanCount = currentCount - 1
        } else {
            self.user.dietPlanCount = 1
        }
        setUserDietPlanCount(self.user.dietPlanCount ?? 0)
    }
    
    func setDefaultDietPlan(_ dietPlan: DietPlan) {
        self.user.defaultDietPlan = dietPlan
    }
    
    func setUserAllergens(_ allergens: [Allergen]) {
        self.user.allergens = allergens
    }
    func setUserSubscriptionEndDate(_ date: Date) {
        self.user.subscriptionEndDate = date
    }
    func setUserIsPremium(_ isPremium: Bool) {
        self.user.isPremium = isPremium
    }
    func setDefaultDietPlanId(_ dietPlanId: String) {
        self.user.defaultDietPlanId = dietPlanId
    }
    func setUserDailyLoginCount(_ count: Int) {
        self.user.dailyLoginCount = count
    }
    
    func setAllUsersDailyLoginCountList(_ userInfo: [UserRankList]) {
        let sortedUserInfo = userInfo.sorted { $0.value ?? 0.0 > $1.value ?? 0.0 }
        self.user.userDailyLoginCountList = sortedUserInfo
    }
    
    func setAllUsersBodyFatPercentageList(_ userInfo: [UserRankList]) {
        let sortedUserInfo = userInfo.sorted { $0.value ?? 0.0 > $1.value ?? 0.0 }
        self.user.userBodyFatPercentageList = sortedUserInfo
    }

    func setAllUsersLeanBodyMassList(_ userInfo: [UserRankList]) {
        let sortedUserInfo = userInfo.sorted { $0.value ?? 0.0 > $1.value ?? 0.0 }
        self.user.userLeanBodyMassList = sortedUserInfo
    }

    func hasDietPlanBeenGenerated() -> Bool {
        return _hasGeneratedDietPlan
    }
    
    func setDietPlanGenerated() {
        _hasGeneratedDietPlan = true
    }
    
    func resetDietPlanGeneration() {
        _hasGeneratedDietPlan = false
    }
    
    func setUserHeartRate(_ heartRate: Double) {
        self.user.heartRate = heartRate
    }
    
    func setUserHRV(_ hrv: Double) {
        self.user.hrv = hrv
    }
    
    func setUserStressLevel(_ stressLevel: String) {
        self.user.stressLevel = stressLevel
    }
    
}
