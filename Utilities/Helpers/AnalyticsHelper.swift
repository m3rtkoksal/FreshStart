//
//  AnalyticsHelper.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseAnalytics
import FirebaseCrashlytics

class AnalyticsHelper {
    static func log(_ eventName: String, eventParameters: [String: String] = [:]) {
        
        var parameters: [String: String] = [:] // Initialize an empty dictionary
        
        for parameter in eventParameters {
            parameters[parameter.key] = parameter.value
        }
        // Fetching build variant information
        if let googleInfoPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let googleInfo_ = NSDictionary(contentsOfFile: googleInfoPath) as? [String: Any] {
            Analytics.logEvent(eventName, parameters: parameters)
        }
    }
    
    static func setUserId(userId: String) {
        Analytics.setUserID(userId)
        Crashlytics.crashlytics().setUserID(userId)
    }
}

// Usage
//AnalyticsHelper.log("kart_başvuru_more_card_başvuru")


