//
//  ContentView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import HealthKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var userInputModel = UserInputModel()
    @StateObject private var prizeManager = PrizeManager()
    @ObservedObject private var authManager = AuthenticationManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var shouldShowRoot = true
    @State var lastDietPlanId: String = ""
    @State private var isDataLoaded = false
    @State private var dailyDietPlanCount: Int = 0
    @State private var dailyLoginCount: Int = 0
    @State private var dailyMealRecreateCount: Int = 0
    @State private var fetchedDietPlans: [DietPlan] = []
    
    var body: some View {
        ZStack {
            if !authManager.hasSeenOnboarding {
                NavigationStack {
                    WalkthroughView()
                        .environmentObject(userInputModel)
                }
            } else if authManager.isLoggedIn {
                if isDataLoaded {
                    NavigationStack {
                        MainTabView()
                            .environmentObject(userInputModel)
                    }
                } else {
                    LottieView(lottieFile: "foodLottie", loopMode: .loop)
                        .background(Color.black)
                        .onAppear {
                            loadAllData()
                        }
                }
            } else {
                NavigationStack {
                    LoginView()
                        .environmentObject(userInputModel)
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            if authManager.isLoggedIn {
                // Check and request notification permission
                NotificationManager.shared.checkAndRequestNotificationPermission { granted in
                    if granted {
                        // Permissions granted, you can proceed with logic that depends on notifications
                        print("Notification permission granted.")
                    } else {
                        // Handle the case when permission is denied
                        print("Notification permission denied.")
                    }
                    
                    // Proceed with loading data if it's not already loaded
                    if !isDataLoaded {
                        loadAllData()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if authManager.isLoggedIn && !isDataLoaded {
                    loadAllData()
                }
            }
        }
    }
    
    private func loadAllData() {
        let group = DispatchGroup()
        var allSuccess = true
        
        // Fetch all users' health data
        group.enter()
        fetchAllUsersHealthData(forWeekStarting: Date()) { healthDataList in
            if healthDataList.isEmpty {
                print("No health data available, proceeding without health data.")
                // Allow continuing without health data
            } else {
                print("Successfully fetched all users' health data.")
            }
            group.leave()
        }
        
        // Fetch all users' login counts
        group.enter()
        fetchAllUsersLoginCounts { userRankList in
            if userRankList.isEmpty {
                print("No login counts available.")
            } else {
                print("Successfully fetched all users' login counts.")
            }
            group.leave()
        }
        
        // Fetch diet plans and default diet plan ID
        group.enter()
        fetchDietPlansAndDefaultDietPlanId { success in
            if !success {
                print("Failed to load diet plans and default diet plan ID.")
            } else {
                print("Successfully loaded diet plans and default diet plan ID.")
            }
            group.leave()
        }
        
        // After all tasks are done, check success status
        group.notify(queue: .main) {
            // Regardless of success or failure in fetching data, allow the flow to proceed
            DispatchQueue.main.async {
                // Ensure we set the data as loaded even if there are failures
                self.isDataLoaded = true
                if allSuccess {
                    self.fetchUserData {
                        self.fetchHealthDataEntries { success in
                            DispatchQueue.main.async {
                                if success {
                                    print("Successfully fetched user health data and completed loading.")
                                } else {
                                    print("Failed to fetch user health data entries, but proceeding.")
                                }
                            }
                        }
                    }
                } else {
                    print("One or more data-fetching operations failed, but proceeding.")
                }
            }
        }
    }

    
    private func fetchHealthDataEntries(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
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
                    self.incrementDailyLogin()
                    if let latestHealthData = fetchedHealthData.first, let lastSavedDate = latestHealthData.createdAt {
                        let timeInterval = Date().timeIntervalSince(lastSavedDate)
                        if timeInterval < 86400 {
                            print("Health data was already saved within the last 24 hours. Skipping save.")
                            ProfileManager.shared.setUserHealthData(from: latestHealthData)
                            completion(true)
                        } else {
                            self.saveHealthDataToFirestore { saveSuccess in
                                if saveSuccess {
                                    ProfileManager.shared.setUserHealthData(from: latestHealthData)
                                }
                                completion(saveSuccess)
                            }
                        }
                    } else {
                        self.saveHealthDataToFirestore { saveSuccess in
                            completion(saveSuccess)
                        }
                    }
                }
            }
    }
    
    private func saveHealthDataToFirestore(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let userId = Auth.auth().currentUser?.uid else {
                completion(false)
                return
            }
            
            HealthKitManager.shared.saveHealthDataToFirestore(
                userId: userId,
                activeEnergy: ProfileManager.shared.user.activeEnergy,
                restingEnergy: ProfileManager.shared.user.restingEnergy,
                bodyFatPercentage: ProfileManager.shared.user.bodyFatPercentage,
                leanBodyMass: ProfileManager.shared.user.leanBodyMass,
                weight: ProfileManager.shared.user.weight,
                gender: ProfileManager.shared.user.gender,
                height: ProfileManager.shared.user.height,
                birthday: ProfileManager.shared.user.birthday,
                heartRate: ProfileManager.shared.user.heartRate,
                hrv: ProfileManager.shared.user.hrv,
                stressLevel: ProfileManager.shared.user.stressLevel
            ) {
                completion(true)
            }
        }
    }
    
    private func fetchUserData(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { document, error in
            if error != nil {
                // Handle error if needed
                completion()
                return
            } else if let document = document, document.exists {
                let data = document.data()
                
                // Fetch subscription end date
                if let subscriptionEndDateTimestamp = data?["subscriptionEndDate"] as? Timestamp {
                    let subscriptionEndDate = subscriptionEndDateTimestamp.dateValue()
                    ProfileManager.shared.setUserSubscriptionEndDate(subscriptionEndDate)
                    
                    // Check if subscription has expired
                    let currentDate = Date()
                    if subscriptionEndDate < currentDate {
                        // Subscription has expired, set isPremiumUser to false
                        self.updatePremiumStatus(userId: userId, isPremium: false)
                    } else {
                        // Subscription is still active, ensure isPremiumUser is true
                        self.updatePremiumStatus(userId: userId, isPremium: true)
                    }
                } else {
                    // If no subscription end date, consider the user as not premium
                    ProfileManager.shared.setUserSubscriptionEndDate(Date()) // Default date
                    self.updatePremiumStatus(userId: userId, isPremium: false)
                }
                
                // Fetch other user data
                ProfileManager.shared.setUserDailyLoginCount(data?["dailyLoginCount"] as? Int ?? 0)
                ProfileManager.shared.setUserFirstName(data?["name"] as? String ?? "")
                ProfileManager.shared.setUserSurname(data?["surname"] as? String ?? "")
                ProfileManager.shared.setUserName(data?["username"] as? String ?? "")
                ProfileManager.shared.setUserEmail(data?["email"] as? String ?? "")
            }
            completion()
        }
    }
    
    private func updatePremiumStatus(userId: String, isPremium: Bool) {
        let db = Firestore.firestore()
        
        // Update the user's premium status in Firestore
        db.collection("users").document(userId).updateData([
            "isPremiumUser": isPremium
        ]) { error in
            if let error = error {
                print("Error updating premium status: \(error.localizedDescription)")
            } else {
                ProfileManager.shared.setUserIsPremium(isPremium)
            }
        }
    }
    
    private func fetchDietPlansAndDefaultDietPlanId(completion: @escaping (Bool) -> Void) {
        // First fetch the diet plans
        fetchDietPlans { success in
            guard success else {
                completion(false)
                return
            }
            
            // Once diet plans are fetched, fetch the default diet plan ID
            self.fetchDefaultDietPlanId { success in
                if success {
                    print("Successfully fetched diet plans and default diet plan ID.")
                    completion(true)
                } else {
                    print("Failed to fetch default diet plan ID.")
                    completion(false)
                }
            }
        }
    }
    
    private func fetchDietPlans(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let db = Firestore.firestore()
        db.collection("dietPlans")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { (querySnapshot, error) in
                
                if let error = error {
                    AnalyticsHelper.log("Error fetching diet plans", eventParameters: ["error" : error.localizedDescription])
                    completion(false)
                    return
                }
                
                for document in querySnapshot?.documents ?? [] {
                    do {
                        var dietPlan = try document.data(as: DietPlan.self)
                        dietPlan.id = document.documentID
                        dietPlan.createdAt = document["createdAt"] as? Date ?? Date()
                        dietPlan.userId = document["userId"] as? String ?? ""
                        dietPlan.purpose = document["purpose"] as? String ?? ""
                        dietPlan.dietPreference = document["dietPreference"] as? String ?? ""
                        
                        if !fetchedDietPlans.contains(where: { $0.id == dietPlan.id }) {
                            if dietPlan.meals.count > 0 {
                                fetchedDietPlans.append(dietPlan)
                            }
                        }
                    } catch {
                        AnalyticsHelper.log("Error decoding diet plan", eventParameters: ["error" : error.localizedDescription])
                    }
                }
                
                fetchedDietPlans.sort {
                    guard let date1 = $0.createdAt, let date2 = $1.createdAt else {
                        return false
                    }
                    return date1 > date2
                }
                
                DispatchQueue.main.async {
                    if let lastDietPlan = fetchedDietPlans.first {
                        ProfileManager.shared.setUserDietPlanCount(fetchedDietPlans.count)
                        self.lastDietPlanId = lastDietPlan.id ?? ""
                        print("the latest diet plan ID: \(lastDietPlanId)")
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
    }
    
    private func fetchDietPlan(byId planId: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("dietPlans").document(planId).getDocument { document, error in
            if let error = error {
                print("Error fetching diet plan by ID: \(error.localizedDescription)")
                completion(false)
            } else if let document = document, let data = document.data() {
                do {
                    var dietPlan = try document.data(as: DietPlan.self)
                    dietPlan.id = document.documentID
                    dietPlan.createdAt = data["createdAt"] as? Date ?? Date()
                    dietPlan.userId = data["userId"] as? String ?? ""
                    dietPlan.purpose = data["purpose"] as? String ?? ""
                    dietPlan.dietPreference = data["dietPreference"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        ProfileManager.shared.setDefaultDietPlan(dietPlan)
                        completion(true)
                    }
                } catch {
                    print("Error decoding diet plan: \(error.localizedDescription)")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func fetchDefaultDietPlanId(completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching default diet plan ID: \(error.localizedDescription)")
                completion(false)
            } else if let data = snapshot?.data(), let planId = data["defaultDietPlanId"] as? String {
                DispatchQueue.main.async {
                    ProfileManager.shared.setDefaultDietPlanId(planId)
                    self.fetchDietPlan(byId: planId) { success in
                        completion(success)
                    }
                }
            } else if !self.lastDietPlanId.isEmpty {
                DispatchQueue.main.async {
                    ProfileManager.shared.setDefaultDietPlanId(self.lastDietPlanId)
                    self.fetchDietPlan(byId: lastDietPlanId) { success in
                        completion(success)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    private func incrementDailyLogin() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                if let lastLoginDate = data["lastLoginDate"] as? Timestamp {
                    let currentDate = Date()
                    let calendar = Calendar.current
                    let lastLogin = lastLoginDate.dateValue()
                    
                    if !calendar.isDateInToday(lastLogin) {
                        // The user hasn't logged in today, reset daily meal and plan counts
                        self.updateLoginData(userRef: userRef, currentDate: currentDate, isPremiumUser: data["isPremiumUser"] as? Bool ?? false)
                    }
                } else {
                    // No login date found, first login
                    self.updateLoginData(userRef: userRef, currentDate: Date(), isPremiumUser: data["isPremiumUser"] as? Bool ?? false)
                }
            } else {
                // No document found, new user
                self.updateLoginData(userRef: userRef, currentDate: Date(), isPremiumUser: false)
            }
        }
    }
    
    private func updateLoginData(userRef: DocumentReference, currentDate: Date, isPremiumUser: Bool) {
        let dietPlanCount = self.fetchedDietPlans.count
        var updatedMaxMealCount = 3
        var updatedMaxPlanCount = 1
        
        if isPremiumUser {
            updatedMaxMealCount = 5
            updatedMaxPlanCount = 3 + dietPlanCount
        }
        
        // Locally increment daily login count
        self.dailyLoginCount = (ProfileManager.shared.user.dailyLoginCount ?? 0) + 1
        ProfileManager.shared.user.dailyLoginCount = self.dailyLoginCount
        
        // Update Firestore
        userRef.updateData([
            "dailyLoginCount": dailyLoginCount,
            "lastLoginDate": Timestamp(date: currentDate),
            "maxMealCount": updatedMaxMealCount,
            "maxPlanCount": updatedMaxPlanCount,
            "isPremiumUser": isPremiumUser
        ]) { error in
            if let error = error {
                print("Error updating login data: \(error.localizedDescription)")
            } else {
                print("Successfully updated login data, daily limits, and incremented login count.")
                
                // Refresh login counts from Firestore
                self.fetchAllUsersLoginCounts { _ in
                    print("Refreshed user login counts after updating.")
                }
            }
        }
    }
    
    private func fetchAllUsersHealthData(forWeekStarting startDate: Date, completion: @escaping ([HealthData]) -> Void) {
        let db = Firestore.firestore()
        
        let startDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        let startTimestamp = Timestamp(date: startDate)
        
        // Calculate end timestamp by adding 7 days
        let endTimestamp = Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: startTimestamp.dateValue())!)
        
        // Debugging logs
        print("Fetching health data from: \(startDate) to \(endTimestamp.dateValue())")
        
        db.collection("healthData")
            .whereField("timestamp", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("timestamp", isLessThan: endTimestamp)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching health data: \(error)")
                    completion([])
                    return
                }
                
                if let querySnapshot = querySnapshot {
                    // Log the documents for further debugging
                    print("Fetched \(querySnapshot.documents.count) health data documents.")
                    var healthDataList: [HealthData] = []
                    for document in querySnapshot.documents {
                        print("Document data: \(document.data())")  // Debugging output
                        if let healthData = try? document.data(as: HealthData.self) {
                            healthDataList.append(healthData)
                            ProfileManager.shared.setUserHealthData(from: healthData)
                        }
                    }
                    completion(healthDataList)
                } else {
                    print("No health data found in the specified range.")
                    completion([])
                }
            }
    }
    
    private func fetchAllUsersLoginCounts(completion: @escaping ([UserRankList]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching user login counts: \(error)")
                completion([])
                return
            }
            
            var userLoginCounts: [UserRankList] = []
            for document in querySnapshot?.documents ?? [] {
                // Get the username and dailyLoginCount values
                let username = document.data()["username"] as? String
                let dailyLoginCount = document.data()["dailyLoginCount"] as? Double
                
                // If the username exists, use it; otherwise, use the document ID (userID)
                let displayName = username ?? document.documentID
                
                // Append the user, either with the username or userID
                if let dailyLoginCount = dailyLoginCount {
                    userLoginCounts.append(UserRankList(id: document.documentID, username: displayName, rank: nil, value: dailyLoginCount))
                }
            }
            ProfileManager.shared.setAllUsersDailyLoginCountList(userLoginCounts)
            completion(userLoginCounts)
        }
    }

    private func genderStringToHKBiologicalSex(_ gender: String) -> HKBiologicalSex? {
        switch gender.lowercased() {
        case "male":
            return .male
        case "female":
            return .female
        case "other":
            return .other
        default:
            return nil
        }
    }
}
