//
//  BadgesVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import HealthKit
import FirebaseAuth
import FirebaseFirestore
import UserNotifications

class BadgesVM: BaseViewModel {
    @ObservedObject private var notificationManager = NotificationManager.shared
    @Published var goToBadgeView: Bool = false
    @Published var goToBadgeDetailView: Bool = false
    @Published var stepsToday: Double = 0
    @Published var badges: [BadgeModel] = []
    private var healthStore = HealthKitManager()
    @Published var healthDataEntries: [HealthData] = []
    
    override init() {
        super.init()
        fetchHealthDataEntries()
        loadBadges()
    }
    
    private func loadBadges() {
        badges = [
            BadgeModel(
                title: "top_fat_burner_badge_title".localized(),
                description: "top_fat_burner_badge_description".localized(),
                iconName: "burn",
                isAchieved: false,
                achievementDate: nil,
                criteria: "top_fat_burner_badge_criteria".localized(),
                color: .buttonRed
            ),
            BadgeModel(
                title: "ultimate_power_walker_badge_title".localized(),
                description: "ultimate_power_walker_badge_description".localized(),
                iconName: "figure.walk.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "ultimate_power_walker_badge_criteria".localized(),
                color: .babyBlue
            ),
            BadgeModel(
                title: "muscle_maker_badge_title".localized(),
                description: "muscle_maker_badge_description".localized(),
                iconName: "bolt.heart.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "muscle_maker_badge_criteria".localized(),
                color: .mkPurple
            ),
            BadgeModel(
                title: "healthy_starter_badge_title".localized(),
                description: "healthy_starter_badge_description".localized(),
                iconName: "leaf.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "healthy_starter_badge_criteria".localized(),
                color: .topGreen
            ),
            BadgeModel(
                title: "Protein Pioneer",
                description: "protein_pioneer_badge_description".localized(),
                iconName: "fork.knife",
                isAchieved: false,
                achievementDate: nil,
                criteria: "protein_pioneer_badge_criteria".localized(),
                color: .mkOrange
            ),
            BadgeModel(
                title: "calorie_crusher_badge_title".localized(),
                description: "calorie_crusher_badge_description".localized(),
                iconName: "flame.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "calorie_crusher_badge_criteria".localized(),
                color: .yellow
            ),
            BadgeModel(
                title: "steady_metabolism_badge_title".localized(),
                description: "steady_metabolism_badge_description".localized(),
                iconName: "mountain.2.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "steady_metabolism_badge_criteria".localized(),
                color: .teal
            ),
            BadgeModel(
                title: "body_builder_badge_title".localized(),
                description: "body_builder_badge_description".localized(),
                iconName: "figure.strengthtraining.traditional",
                isAchieved: false,
                achievementDate: nil,
                criteria: "body_builder_badge_criteria".localized(),
                color: .pink
            ),
            BadgeModel(
                title: "active_energy_burner_badge_title".localized(),
                description: "active_energy_burner_badge_description".localized(),
                iconName: "battery.100",
                isAchieved: false,
                achievementDate: nil,
                criteria: "active_energy_burner_badge_criteria".localized(),
                color: .cyan
            ),
            BadgeModel(
                title: "strength_gainer_badge_title".localized(),
                description: "strength_gainer_badge_description".localized(),
                iconName: "dumbbell",
                isAchieved: false,
                achievementDate: nil,
                criteria: "strength_gainer_badge_criteria".localized(),
                color: .brown
            ),
            BadgeModel(
                title: "weight_watcher_badge_title".localized(),
                description: "weight_watcher_badge_description".localized(),
                iconName: "eye.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "weight_watcher_badge_criteria".localized(),
                color: .gray
            ),
            BadgeModel(
                title: "step_master_badge_title".localized(),
                description: "step_master_badge_description".localized(),
                iconName: "figure.walk",
                isAchieved: stepsToday >= 8000,
                achievementDate: stepsToday >= 8000 ? Date() : nil,
                criteria: "step_master_badge_criteria".localized(),
                color: .indigo
            ),
            BadgeModel(
                title: "slim_shady_badge_title".localized(),
                description: "slim_shady_badge_description".localized(),
                iconName: "figure.dance",
                isAchieved: false,
                achievementDate: nil,
                criteria: "slim_shady_badge_criteria".localized(),
                color: .mint
            ),
            BadgeModel(
                title: "water_tank_badge_title".localized(),
                description: "water_tank_badge_description".localized(),
                iconName: "drop.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "water_tank_badge_criteria".localized(),
                color: .bottomBlue
            ),
            BadgeModel(
                title: "calm_pulse_badge_title".localized(),
                description: "calm_pulse_badge_description".localized(),
                iconName: "heart.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "calm_pulse_badge_criteria".localized(),
                color: .red
            ),
            BadgeModel(
                title: "balanced_rhythm_badge_title".localized(),
                description: "balanced_rhythm_badge_description".localized(),
                iconName: "waveform.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "balanced_rhythm_badge_criteria".localized(),
                color: .blue
            ),
            BadgeModel(
                title: "stress_resistor_badge_title".localized(),
                description: "stress_resistor_badge_description".localized(),
                iconName: "face.smiling.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "stress_resistor_badge_criteria".localized(),
                color: .green
            ),
            BadgeModel(
                title: "wellness_warrior_badge_title".localized(),
                description: "wellness_warrior_badge_description".localized(),
                iconName: "star.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "wellness_warrior_badge_criteria".localized(),
                color: .yellow
            ),
            BadgeModel(
                title: "notification_master_badge_title".localized(),
                description: "notification_master_badge_description".localized(),
                iconName: "bell.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "notification_master_badge_criteria".localized(),
                color: .blue
            )
        ]
    }
    
    func checkBadges() {
        checkStrengthGainerBadge()
        checkWeightWatcherBadge()
        checkActiveEnergyBurnerBadge()
        checkBodyBuilderBadge()
        checkSteadyMetabolismBadge()
        checkTopFatBurnerBadge()
        checkCombinedStepAndActiveEnergyBadge()
        checkWeightLossAchievement()
        checkWaterTankBadge()
        checkHeartRateControlBadge()
        checkHRVImprovementBadge()
        checkStressManagementBadge()
        checkDailyWellnessChampionBadge()
        checkNotificationMasterBadge()
    }
    private func updateBadge(title: String, isAchieved: Bool, achievementDate: Date?) {
        if let index = badges.firstIndex(where: { $0.title == title }) {
            badges[index].isAchieved = isAchieved
            badges[index].achievementDate = achievementDate
        }
    }
    //MARK: Notification
    func checkNotificationMasterBadge() {
        // Request permission and handle the result asynchronously
        notificationManager.requestNotificationPermission { granted in
            if granted {
                self.notificationManager.hasScheduledNotifications { hasScheduled in
                    if hasScheduled {
                        self.updateBadge(title: "notification_master_badge_title".localized(), isAchieved: true, achievementDate: Date())
                    } else {
                        self.updateBadge(title: "notification_master_badge_title".localized(), isAchieved: false, achievementDate: nil)
                    }
                }
            } else {
                self.updateBadge(title: "notification_master_badge_title".localized(), isAchieved: false, achievementDate: nil)
            }
        }
    }
    
    //MARK: Step Master
    private func updateStepMasterBadge() {
        if let stepMasterIndex = badges.firstIndex(where: { $0.title == "step_master_badge_title".localized() }) {
            let isAchieved = ProfileManager.shared.user.steps ?? 0 >= 10000
            badges[stepMasterIndex].isAchieved = isAchieved
            badges[stepMasterIndex].achievementDate = isAchieved ? Date() : nil
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
                                return date1 > date2
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
                    self.checkBadges()
                }
            }
    }
    //MARK: Heart Rate Control
    func checkHeartRateControlBadge() {
        let targetHeartRate = 70.0
        let daysRequired = 7
        let recentEntries = healthDataEntries.prefix(daysRequired)
        
        let isAchieved = recentEntries.allSatisfy { entry in
            guard let restingHeartRate = entry.heartRate else { return false }
            return restingHeartRate <= targetHeartRate
        }
        
        updateBadge(title: "calm_pulse_badge_title".localized(), isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
    }
    
    //MARK: HRV
    func checkHRVImprovementBadge() {
        let daysRequired = 30
        let recentEntries = healthDataEntries.prefix(daysRequired)
        
        // Calculate improvement percentage
        guard let firstEntry = recentEntries.last,
              let lastEntry = recentEntries.first,
              let startHRV = firstEntry.hrv,
              let endHRV = lastEntry.hrv else {
            updateBadge(title: "balanced_rhythm_badge_title".localized(), isAchieved: false, achievementDate: nil)
            return
        }
        
        let improvement = ((endHRV - startHRV) / startHRV) * 100
        let isAchieved = improvement >= 10
        
        updateBadge(title: "balanced_rhythm_badge_title".localized(), isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
    }
    //MARK: Stress Level
    func checkStressManagementBadge() {
        let allowedStressLevels = ["Low Stress", "Moderate Stress"]
        let daysRequired = 10
        let recentEntries = healthDataEntries.prefix(daysRequired)
        
        let isAchieved = recentEntries.allSatisfy { entry in
            guard let stressLevel = entry.stressLevel else { return false }
            return allowedStressLevels.contains(stressLevel)
        }
        
        updateBadge(title: "stress_resistor_badge_title".localized(), isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
    }
    //MARK: Wellness
    func checkDailyWellnessChampionBadge() {
        guard let lastEntry = healthDataEntries.first else { return }
        
        let targetHeartRate = 70.0
        let allowedStressLevels = ["Low Stress", "Moderate Stress"]
        let hrvImprovement = 5.0 // Assuming this is a minimum threshold value
        
        // Ensure all conditions are met
        let isAchieved = (lastEntry.heartRate ?? 0) <= targetHeartRate &&
        allowedStressLevels.contains(lastEntry.stressLevel ?? "") &&
        (lastEntry.hrv ?? 0) >= hrvImprovement
        
        updateBadge(title: "wellness_warrior_badge_title".localized(), isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
    }
    
    //MARK: Water Tank
    func checkWaterTankBadge() {
        let defaults = UserDefaults.standard
        let waterEntries = MealManager.shared.loadWaterEntries()
        var consecutiveDays = 0
        let goalIntake = 2000
        
        for entry in waterEntries.reversed() {
            if entry.waterIntake >= goalIntake {
                consecutiveDays += 1
            } else {
                break
            }
        }
        if consecutiveDays >= 30 {
            updateBadge(title: "water_tank_badge_title".localized(), isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "water_tank_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    
    //MARK: Slim Shady
    func checkWeightLossAchievement() {
        // Ensure there are at least two entries
        guard let firstEntry = healthDataEntries.first, let lastEntry = healthDataEntries.last,
              let lastWeight = lastEntry.weight ,let firstWeight = firstEntry.weight else { return }
        
        let weightLoss = lastWeight - firstWeight
        
        if weightLoss >= 10, let latestDate = lastEntry.createdAt {
            updateBadge(title: "slim_shady_badge_title".localized(), isAchieved: true, achievementDate: latestDate)
        } else {
            updateBadge(title: "slim_shady_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Weight Watcher
    private func checkWeightWatcherBadge() {
        guard let latestEntry = healthDataEntries.first, let oldestEntry = healthDataEntries.last,
              let latestWeight = latestEntry.weight, let oldestWeight = oldestEntry.weight else { return }
        
        let weightDifference = latestWeight - oldestWeight
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        if weightDifference <= -2, let latestDate = latestEntry.createdAt, latestDate >= oneMonthAgo {
            updateBadge(title: "weight_watcher_badge_title".localized(), isAchieved: true, achievementDate: latestDate)
        } else {
            updateBadge(title: "weight_watcher_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Strength Gainer
    private func checkStrengthGainerBadge() {
        guard let latestEntry = healthDataEntries.first, let oldestEntry = healthDataEntries.last,
              let latestLeanBodyMass = latestEntry.leanBodyMass, let oldestLeanBodyMass = oldestEntry.leanBodyMass else { return }
        
        let leanBodyMassChange = latestLeanBodyMass - oldestLeanBodyMass
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        if leanBodyMassChange >= 1.0, let latestDate = latestEntry.createdAt, latestDate >= oneMonthAgo {
            updateBadge(title: "strength_gainer_badge_title".localized(), isAchieved: true, achievementDate: latestDate)
        } else {
            updateBadge(title: "strength_gainer_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Active Energy
    private func checkActiveEnergyBurnerBadge() {
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        let weeklyEntries = healthDataEntries.filter { entry in
            guard let createdAt = entry.createdAt else { return false }
            return createdAt >= oneWeekAgo
        }
        
        let totalActiveEnergy = weeklyEntries.reduce(into: 0) { (total, entry) in
            total += (entry.activeEnergy ?? 0)
        }
        let threshold: Double = 20000
        
        if totalActiveEnergy >= threshold {
            updateBadge(title: "active_energy_burner_badge_title".localized(), isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "active_energy_burner_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Body Builder
    private func checkBodyBuilderBadge() {
        // Fetch health data entries for the past two weeks
        let twoWeeksAgo = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date()
        let recentEntries = healthDataEntries.filter { entry in
            guard let createdAt = entry.createdAt else { return false }
            return createdAt >= twoWeeksAgo
        }
        let sortedEntries = recentEntries.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
        
        guard let firstEntry = sortedEntries.first, let lastEntry = sortedEntries.last else {
            // Not enough data to compare
            return
        }
        // Compare the weight or lean body mass between the first and last entries
        let weightGain = (lastEntry.weight ?? 0) - (firstEntry.weight ?? 0) // Adjust this to use lean body mass if applicable
        
        // Set the threshold for gaining 1kg of lean mass
        let threshold: Double = 1.0 // 1kg increase in weight or lean body mass
        
        // If the weight gain is above or equal to the threshold, update the badge as achieved
        if weightGain >= threshold {
            updateBadge(title: "body_builder_badge_title".localized(), isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "body_builder_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Steady Metabolism
    private func checkSteadyMetabolismBadge() {
        // Fetch health data entries for the past 7 days
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let lastSevenDaysEntries = healthDataEntries.filter { entry in
            guard let createdAt = entry.createdAt else { return false }
            return createdAt >= sevenDaysAgo
        }
        
        // Sort entries by date to group them by day
        let sortedEntries = lastSevenDaysEntries.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
        
        // Create a dictionary to group by date
        var dailyBMRs: [Date: Double] = [:]
        
        for entry in sortedEntries {
            guard let createdAt = entry.createdAt else { continue }
            let dateOnly = Calendar.current.startOfDay(for: createdAt)
            
            // Assuming BMR is tracked as `basalEnergyBurned` or similar property
            let dailyBMR = entry.restingEnergy ?? 0
            
            // Add BMR for each day
            dailyBMRs[dateOnly, default: 0] += dailyBMR
        }
        // Check if all 7 days have a basal energy burn of 1500+ calories
        let threshold: Double = 1500
        let isAchieved = dailyBMRs.count == 7 && dailyBMRs.values.allSatisfy { $0 >= threshold }
        
        if isAchieved {
            updateBadge(title: "steady_metabolism_badge_title".localized(), isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "steady_metabolism_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Top Fat Burner
    private func checkTopFatBurnerBadge() {
        let oneWeekAgo = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        let weeklyEntries = healthDataEntries.filter { entry in
            guard let createdAt = entry.createdAt else { return false }
            return createdAt >= oneWeekAgo
        }
        guard weeklyEntries.count >= 2 else {
            print("Not enough data to calculate fat burned!")
            updateBadge(title: "top_fat_burner_badge_title".localized(), isAchieved: false, achievementDate: nil)
            return
        }
        let sortedEntries = weeklyEntries.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
        
        guard let userWeight = getUserWeight() else {
            print("User weight data is missing!")
            return
        }
        guard
            let firstEntry = sortedEntries.first,
            let lastEntry = sortedEntries.last,
            let startBodyFatPercentage = firstEntry.bodyFatPercentage,
            let endBodyFatPercentage = lastEntry.bodyFatPercentage,
            let userWeight = getUserWeight()
        else {
            print("Data is incomplete!")
            updateBadge(title: "top_fat_burner_badge_title".localized(), isAchieved: false, achievementDate: nil)
            return
        }
        
        let startFatMass = startBodyFatPercentage * userWeight
        let endFatMass = endBodyFatPercentage * userWeight
        
        let totalFatBurned = startFatMass - endFatMass
        
        let threshold: Double = 2.0 // 2 kg
        if totalFatBurned >= threshold {
            updateBadge(title: "top_fat_burner_badge_title".localized(), isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "top_fat_burner_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    
    private func getUserWeight() -> Double? {
        return ProfileManager.shared.user.weight
    }
    
    private func checkCombinedStepAndActiveEnergyBadge() {
        // Define the required thresholds
        let stepThreshold: Int = 10000
        let activeEnergyThreshold: Double = 500
        
        // Fetch today's health data entry (for steps and active energy)
        guard let todayEntry = healthDataEntries.first(where: {
            guard let createdAt = $0.createdAt else { return false }
            let calendar = Calendar.current
            return calendar.isDateInToday(createdAt)
        }) else {
            // No entry found for today
            return
        }
        
        // Check if both conditions are met (steps and active energy)
        let hasAchievedSteps = ProfileManager.shared.user.steps ?? 0 >= Int(stepThreshold)
        let hasAchievedActiveEnergy = todayEntry.activeEnergy ?? 0 >= activeEnergyThreshold
        
        // Update the combined badge status
        if hasAchievedSteps && hasAchievedActiveEnergy {
            updateBadge(title: "ultimate_power_walker_badge_title".localized(), isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "ultimate_power_walker_badge_title".localized(), isAchieved: false, achievementDate: nil)
        }
    }
    
}
