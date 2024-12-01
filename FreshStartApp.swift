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

@main
struct FreshStartApp: App {
    init() {
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
                handleDailyLogin()
            case .background:
                NotificationManager.shared.stopInactivityTimer()   // Stop timer when app goes to background
            default:
                break
            }
        }
    }
    
    private func handleDailyLogin() {
        guard authManager.isLoggedIn, let userId = Auth.auth().currentUser?.uid else { return }
        
        let userRef = Firestore.firestore().collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists, let data = document.data() {
                if let lastLoginDate = data["lastLoginDate"] as? Timestamp {
                    let currentDate = Date()
                    let calendar = Calendar.current
                    let lastLogin = lastLoginDate.dateValue()
                    
                    if !calendar.isDateInToday(lastLogin) {
                        updateDailyLoginData(userRef: userRef, currentDate: currentDate, isPremiumUser: data["isPremiumUser"] as? Bool ?? false)
                    }
                } else {
                    // First login, no previous date
                    updateDailyLoginData(userRef: userRef, currentDate: Date(), isPremiumUser: data["isPremiumUser"] as? Bool ?? false)
                }
            } else {
                // No user document, create new entry
                updateDailyLoginData(userRef: userRef, currentDate: Date(), isPremiumUser: false)
            }
        }
    }
    
    private func updateDailyLoginData(userRef: DocumentReference, currentDate: Date, isPremiumUser: Bool) {
        var updatedMaxMealCount = 1
        var updatedMaxPlanCount = 1
        
        if isPremiumUser {
            updatedMaxMealCount = 3
            updatedMaxPlanCount = 3 + ProfileManager.shared.user.dietPlans.count
        }
        
        userRef.updateData([
            "dailyLoginCount": FieldValue.increment(Int64(1)),
            "lastLoginDate": Timestamp(date: currentDate),
            "maxMealCount": updatedMaxMealCount,
            "maxPlanCount": updatedMaxPlanCount
        ]) { error in
            if let error = error {
                print("Error updating login data: \(error.localizedDescription)")
            } else {
                print("Daily login updated successfully.")
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
            // Initialize AppCheck with DeviceCheck provider
            let providerFactory = DeviceCheckProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
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
