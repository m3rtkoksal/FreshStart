//
//  NotificationManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var areNotificationsEnabled: Bool = false
    private var inactivityTimer: Timer?
    var lastInteractionDate: Date?

    private init() {
        checkNotificationSettings()
        startGlobalInactivityTimer()
    }

    // Check if notifications are enabled
    func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.areNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    // Check and request notification permission if necessary
    func checkAndRequestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    self.requestNotificationPermission { granted in
                        completion(granted)
                    }
                } else {
                    self.areNotificationsEnabled = settings.authorizationStatus == .authorized
                    completion(self.areNotificationsEnabled)
                }
            }
        }
    }
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.areNotificationsEnabled = granted
                completion(granted)
            }
        }
    }

    // Start the global inactivity timer (4 hours)
    private func startGlobalInactivityTimer() {
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 4 * 60 * 60, repeats: true) { _ in
            self.checkGlobalInactivity()
        }
    }

    // Stop the inactivity timer (useful when the app is backgrounded or not active)
    func stopInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }

    // Check if the user has been inactive for more than 4 hours
    func checkGlobalInactivity() {
        guard let lastInteractionDate = lastInteractionDate else {
            print("No last interaction date set.")
            return
        }
        let inactivityThreshold: TimeInterval = 4 * 60 * 60 // 4 hours (or 10 seconds for testing)
        let timeElapsed = Date().timeIntervalSince(lastInteractionDate)
        
        if timeElapsed > inactivityThreshold {
            print("User has been inactive for \(timeElapsed) seconds. Sending reminder.")
            sendMealReminderNotification()
        } else {
            print("User is still active. Time elapsed: \(timeElapsed) seconds.")
        }
    }

    // Check if the user has been inactive for too long to trigger "forgot to select" reminder
    func checkForgotToSelectReminder() {
        guard let lastInteractionDate = lastInteractionDate else { return }
        let inactivityThreshold: TimeInterval = 2 * 60 * 60
        if Date().timeIntervalSince(lastInteractionDate) > inactivityThreshold {
            self.sendMealReminderNotification()
        }
    }

    // Start or reset the inactivity timer when the user interacts
    func startInactivityTimer() {
        print("Starting inactivity timer")
        lastInteractionDate = Date()
        inactivityTimer?.invalidate()
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: 4 * 60 * 60, repeats: true) { _ in
            print("Inactivity timer fired")
            self.checkGlobalInactivity()
        }
    }

    func invalidateInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
    }
    
    func sendReminderNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Trigger notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully: \(title) - \(body)")
            }
        }
    }

    // Send a notification to remind the user to select a meal if they haven't done so in 2 hours
    private func sendMealReminderNotification() {
        guard areNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "It looks like you haven't selected a meal yet. Don't forget to plan your meals!"
        content.sound = .default
        
        // Send notification immediately
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    // Check if there are any pending notifications scheduled
    func hasScheduledNotifications(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(!requests.isEmpty)
        }
    }

    // Send a global inactivity reminder after 4 hours
    private func sendGlobalInactivityReminder() {
        guard areNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "It's been a while!"
        content.body = "You haven't interacted with the app for a while. Don't forget to check your meal plan!"
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling global reminder notification: \(error.localizedDescription)")
            }
        }
    }

    func checkPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications count: \(requests.count)")
            if requests.isEmpty {
                print("No scheduled notifications.")
            } else {
                print("Scheduled notifications: \(requests)")
            }
        }
    }

    // Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
