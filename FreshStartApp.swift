//
//  FreshStartApp.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck
import GoogleSignIn
import FirebaseFirestore
import FirebaseAuth
import GoogleMobileAds

@main
struct FreshStartApp: App {
    init() {
        // Check if a selected language exists in UserDefaults
        if let savedLanguageRawValue = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let savedLanguage = LanguageType(rawValue: savedLanguageRawValue) {
            // If there's a saved language, use it
            LanguageHelper.shared.setLanguage(savedLanguage)
            print("Using saved language: \(savedLanguage.rawValue)")
        } else {
            // If no saved language, use the device's preferred language
            let deviceLanguage = LanguageHelper.shared.deviceLanguage
            LanguageHelper.shared.setLanguage(deviceLanguage)
            print("Using device language: \(deviceLanguage.rawValue)")
        }
        
        // Disable bounces on UIScrollView globally
        UIScrollView.appearance().bounces = false
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var router = BindingRouter()
    @State private var isKeysConfigured = false
    @Environment(\.scenePhase) private var scenePhase
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            if isKeysConfigured {
                ContentView()
                    .dynamicTypeSize(.large)
                    .environmentObject(router)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .onAppear {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        }
                    }
            } else {
                LottieView(lottieFile: "foodLottie", loopMode: .loop)
                    .background(Color.black)
                    .onOpenURL { url in
                        GIDSignIn.sharedInstance.handle(url)
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            setupRevenueCatAndOpenAI()
                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in }
                            NotificationManager.shared.startInactivityTimer()
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                NotificationManager.shared.startInactivityTimer()
                fetchDietPlanCount { dietPlanCount in
                    handleDailyLogin(dietPlanCount: dietPlanCount)
                }
                
            case .background:
                NotificationManager.shared.stopInactivityTimer()
            default:
                break
            }
        }
    }
    
    private func handleDailyLogin(dietPlanCount: Int) {
        guard authManager.isLoggedIn, let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                if let lastLoginDate = data["lastLoginDate"] as? Timestamp {
                    let currentDate = Date()
                    let calendar = Calendar.current
                    let lastLogin = lastLoginDate.dateValue()
                    
                    if !calendar.isDateInToday(lastLogin) {
                        updateDailyLoginData(userRef: userRef, currentDate: currentDate, isPremiumUser: data["isPremiumUser"] as? Bool ?? false, dietPlanCount: dietPlanCount)
                    }
                } else {
                    // First login, no previous date
                    updateDailyLoginData(userRef: userRef, currentDate: Date(), isPremiumUser: data["isPremiumUser"] as? Bool ?? false, dietPlanCount: dietPlanCount)
                }
            } else {
                // No user document, create new entry
                updateDailyLoginData(userRef: userRef, currentDate: Date(), isPremiumUser: false, dietPlanCount: dietPlanCount)
            }
        }
    }
    
    private func updateDailyLoginData(userRef: DocumentReference, currentDate: Date, isPremiumUser: Bool, dietPlanCount: Int) {
        var updatedMaxMealCount = 3
        var updatedMaxPlanCount = 1
        
        if isPremiumUser {
            updatedMaxMealCount = 5
            updatedMaxPlanCount = 3 + dietPlanCount
        }
        
        userRef.updateData([
            "dailyLoginCount": FieldValue.increment(Int64(1)),
            "lastLoginDate": Timestamp(date: currentDate),
            "maxMealCount": updatedMaxMealCount,
            "maxPlanCount": updatedMaxPlanCount,
            "isPremiumUser": isPremiumUser
        ]) { error in
            if let error = error {
                print("Error updating login data: \(error.localizedDescription)")
            } else {
                print("Daily login updated successfully.")
            }
        }
    }
    
    func fetchDietPlanCount(completion: @escaping (Int) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found.")
            completion(0)
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
                completion(0)
                return
            }
            
            // Try to fetch the default diet plan ID from the user's document
            if let data = snapshot?.data(),
               let planId = data["defaultDietPlanId"] as? String {
                // If a default plan ID exists, count the diet plans related to the user
                Firestore.firestore().collection("dietPlans").whereField("userId", isEqualTo: userId).getDocuments { querySnapshot, queryError in
                    if let queryError = queryError {
                        print("Error fetching diet plans count: \(queryError.localizedDescription)")
                        completion(0)
                        return
                    }
                    
                    // Return the count of documents in the query result
                    let count = querySnapshot?.documents.count ?? 0
                    ProfileManager.shared.setUserDietPlanCount(count)
                    completion(count)
                }
            } else {
                print("No default diet plan ID found in user document.")
                completion(0)
            }
        }
    }
    
    private func setupRevenueCatAndOpenAI() {
        RemoteConfigManager.shared.fetchAPIKeys { openAIKey in
            if let openAIKey = openAIKey {
                KeychainManager.shared.saveToKeychain(data: openAIKey, forKey: .openAIKey)
                print("OpenAIAPIKey configured successfully.")
                isKeysConfigured = true
            }
            else {
//                AnalyticsHelper.log("Failed to fetch RevenueCat API key.", eventParameters:[:])
            }
        }
    }

    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
            FirebaseApp.configure()
            let providerFactory = DeviceCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            // Set test device identifiers
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [GADSimulatorID]
            return true
        }
        
        func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return .portrait
        }
        
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
            return GIDSignIn.sharedInstance.handle(url)
        }
        
    }
}
