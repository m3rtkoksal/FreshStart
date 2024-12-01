//
//  AuthenticationManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import Combine

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    private let isLoggedInKey = "isLoggedIn"
    private let hasSeenOnboardingKey = "hasSeenOnboarding"
    
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: isLoggedInKey)
        }
    }
    
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: hasSeenOnboardingKey)
        }
    }
    
    private init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: hasSeenOnboardingKey)
    }
    
    func logIn() {
        isLoggedIn = true
    }
    
    func logOut() {
        isLoggedIn = false
    }
    
    func completeOnboarding() {
        hasSeenOnboarding = true
    }
}
