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
                title: "Top Fat Burner",
                description: "Awarded for burning the most fat this week.",
                iconName: "burn",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Burn 2kg of fat in one week.",
                color: .buttonRed
            ),
            BadgeModel(
                title: "The Ultimate Power Walker",
                description: "Complete 10,000 steps and burn 500 active calories in a single day.",
                iconName: "figure.walk.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Complete 10,000 steps and burn 500 active calories in a single day.",
                color: .babyBlue
            ),
            BadgeModel(
                title: "Muscle Maker",
                description: "Awarded for gaining the most muscle this week.",
                iconName: "bolt.heart.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Gain 3kg of muscle in one week.",
                color: .mkPurple
            ),
            BadgeModel(
                title: "Healthy Starter",
                description: "Successfully complete your first diet plan.",
                iconName: "leaf.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Follow a full diet plan for one week.",
                color: .topGreen
            ),
            BadgeModel(
                title: "Protein Pioneer",
                description: "Achieve 150g of protein intake in a day.",
                iconName: "fork.knife",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Consume 150g or more protein in a single day.",
                color: .mkOrange
            ),
            BadgeModel(
                title: "Calorie Crusher",
                description: "Awarded for burning 500 active calories in a single day.",
                iconName: "flame.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Burn 500 active calories in one day.",
                color: .yellow
            ),
            BadgeModel(
                title: "Steady Metabolism",
                description: "Maintain a consistent basal metabolic rate for a week.",
                iconName: "mountain.2.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Basal energy burn of 1500+ calories for 7 days.",
                color: .teal
            ),
            BadgeModel(
                title: "Body Builder",
                description: "Gain 1kg of lean body mass within two weeks.",
                iconName: "figure.strengthtraining.traditional",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Increase lean body mass by 1 kg over two weeks.",
                color: .pink
            ),
            BadgeModel(
                title: "Active Energy Burner",
                description: "Awarded for burning 20.000 kcal in one week.",
                iconName: "battery.100",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Burn the most active energy in a single week.",
                color: .cyan
            ),
            BadgeModel(
                title: "Strength Gainer",
                description: "Awarded for increasing lean body mass in one month.",
                iconName: "dumbbell",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Increase lean body mass by 1 kg in one month.",
                color: .brown
            ),
            BadgeModel(
                title: "Weight Watcher",
                description: "Awarded for losing weight consistently over the course of a month.",
                iconName: "eye.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Lose 2 kg of body weight in one month.",
                color: .gray
            ),
            BadgeModel(
                title: "Step Master",
                description: "Awarded for completing 8,000 steps today!",
                iconName: "figure.walk",
                isAchieved: stepsToday >= 8000,
                achievementDate: stepsToday >= 8000 ? Date() : nil,
                criteria: "Complete 10,000 steps in a day.",
                color: .indigo
            ),
            BadgeModel(
                title: "Slim Shady",
                description: "Awarded for losing 10kg weight consistently",
                iconName: "figure.dance",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Lose 10 kg of body weight.",
                color: .mint
            ),
            BadgeModel(
                title: "Water Tank",
                description: "Awarded for drinking 2 litres of water for 30 days.",
                iconName: "drop.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Drink 2 litres of water for 30 days.",
                color: .bottomBlue
            ),
            BadgeModel(
                title: "Calm Pulse",
                description: "Keep your resting heart rate under 70 bpm for a week.",
                iconName: "heart.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Average resting heart rate ≤ 70 bpm for 7 consecutive days.",
                color: .red
            ),
            BadgeModel(
                title: "Balanced Rhythm",
                description: "Improve your HRV by 10% within a month.",
                iconName: "waveform.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "10% increase in average HRV over 30 days.",
                color: .blue
            ),
            BadgeModel(
                title: "Stress Resistor",
                description: "Maintain a low stress score (<3) for 10 days.",
                iconName: "face.smiling.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Daily stress score of ≤ 3 for 10 consecutive days.",
                color: .green
            ),
            BadgeModel(
                title: "Wellness Warrior",
                description: "Meet your heart rate, HRV, and stress level goals in a single day.",
                iconName: "star.circle.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Resting heart rate ≤ 70 bpm, HRV increase by 5%, stress score ≤ 3 for a day.",
                color: .yellow
            ),
            BadgeModel(
                title: "Notification Master",
                description: "Ensure that local notifications are enabled and scheduled.",
                iconName: "bell.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Local notifications enabled and at least one notification scheduled.",
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
                        self.updateBadge(title: "Notification Master", isAchieved: true, achievementDate: Date())
                    } else {
                        self.scheduleTestNotification()
                        self.updateBadge(title: "Notification Master", isAchieved: false, achievementDate: nil)
                    }
                }
            } else {
                self.updateBadge(title: "Notification Master", isAchieved: false, achievementDate: nil)
            }
        }
    }
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Notification Master"
        content.body = "Notification Master is available!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)  // Notify after 5 seconds
        
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled.")
            }
        }
    }

    //MARK: Step Master
    private func updateStepMasterBadge() {
        if let stepMasterIndex = badges.firstIndex(where: { $0.title == "Step Master" }) {
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
        
        updateBadge(title: "Calm Pulse", isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
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
            updateBadge(title: "Balanced Rhythm", isAchieved: false, achievementDate: nil)
            return
        }
        
        let improvement = ((endHRV - startHRV) / startHRV) * 100
        let isAchieved = improvement >= 10
        
        updateBadge(title: "Balanced Rhythm", isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
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

        updateBadge(title: "Stress Resistor", isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
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

        updateBadge(title: "Wellness Warrior", isAchieved: isAchieved, achievementDate: isAchieved ? Date() : nil)
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
            updateBadge(title: "Water Tank", isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "Water Tank", isAchieved: false, achievementDate: nil)
        }
    }

    //MARK: Slim Shady
    func checkWeightLossAchievement() {
        // Ensure there are at least two entries
        guard let firstEntry = healthDataEntries.first, let lastEntry = healthDataEntries.last,
              let lastWeight = lastEntry.weight ,let firstWeight = firstEntry.weight else { return }

        let weightLoss = lastWeight - firstWeight
        
        if weightLoss >= 10, let latestDate = lastEntry.createdAt {
            updateBadge(title: "Slim Shady", isAchieved: true, achievementDate: latestDate)
        } else {
            updateBadge(title: "Slim Shady", isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Weight Watcher
    private func checkWeightWatcherBadge() {
        guard let latestEntry = healthDataEntries.first, let oldestEntry = healthDataEntries.last,
              let latestWeight = latestEntry.weight, let oldestWeight = oldestEntry.weight else { return }
        
        let weightDifference = latestWeight - oldestWeight
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        if weightDifference <= -2, let latestDate = latestEntry.createdAt, latestDate >= oneMonthAgo {
            updateBadge(title: "Weight Watcher", isAchieved: true, achievementDate: latestDate)
        } else {
            updateBadge(title: "Weight Watcher", isAchieved: false, achievementDate: nil)
        }
    }
    //MARK: Strength Gainer
    private func checkStrengthGainerBadge() {
        guard let latestEntry = healthDataEntries.first, let oldestEntry = healthDataEntries.last,
              let latestLeanBodyMass = latestEntry.leanBodyMass, let oldestLeanBodyMass = oldestEntry.leanBodyMass else { return }
        
        let leanBodyMassChange = latestLeanBodyMass - oldestLeanBodyMass
        let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        
        if leanBodyMassChange >= 1.0, let latestDate = latestEntry.createdAt, latestDate >= oneMonthAgo {
            updateBadge(title: "Strength Gainer", isAchieved: true, achievementDate: latestDate)
        } else {
            updateBadge(title: "Strength Gainer", isAchieved: false, achievementDate: nil)
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
            updateBadge(title: "Active Energy Burner", isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "Active Energy Burner", isAchieved: false, achievementDate: nil)
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
            updateBadge(title: "Body Builder", isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "Body Builder", isAchieved: false, achievementDate: nil)
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
            updateBadge(title: "Steady Metabolism", isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "Steady Metabolism", isAchieved: false, achievementDate: nil)
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
            updateBadge(title: "Top Fat Burner", isAchieved: false, achievementDate: nil)
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
            updateBadge(title: "Top Fat Burner", isAchieved: false, achievementDate: nil)
            return
        }
        
        let startFatMass = startBodyFatPercentage * userWeight
        let endFatMass = endBodyFatPercentage * userWeight
        
        let totalFatBurned = startFatMass - endFatMass
        
        let threshold: Double = 2.0 // 2 kg
        if totalFatBurned >= threshold {
            updateBadge(title: "Top Fat Burner", isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "Top Fat Burner", isAchieved: false, achievementDate: nil)
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
            updateBadge(title: "The Ultimate Power Walker", isAchieved: true, achievementDate: Date())
        } else {
            updateBadge(title: "The Ultimate Power Walker", isAchieved: false, achievementDate: nil)
        }
    }
    
}
