//
//  HowActiveYouVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

enum ActivityLevel: String, CaseIterable {
    case notVeryActive = "not_very_active"
    case lightlyActive = "lightly_active"
    case active = "active"
    case veryActive = "very_active"
    
    var localizedTitle: String {
        switch self {
        case .notVeryActive:
            return "not_very_active_title".localized()
        case .lightlyActive:
            return "lightly_active_title".localized()
        case .active:
            return "active_title".localized()
        case .veryActive:
            return "very_active_title".localized()
        }
    }
    var description: String {
        switch self {
        case .notVeryActive:
            return "not_very_active_description".localized()
        case .lightlyActive:
            return "lightly_active_description".localized()
        case .active:
            return "active_description".localized()
        case .veryActive:
            return "very_active_description".localized()
        }
    }
}

class HowActiveYouVM: BaseViewModel {
    @Published var goToPurpose = false
    @Published var activityItems: [ActivityItem] = []
    @Published var selectedActivity: ActivityItem?
    
    func fetchActivityItems() {
        self.activityItems = ActivityLevel.allCases.map { level in
            ActivityItem(title: level.localizedTitle, subtitle: level.description)
        }
    }
    
    func selectActivityBasedOnEnergy(activeEnergy: Double) {
            let activityLevel: ActivityLevel
            switch activeEnergy {
            case 0..<250:
                activityLevel = .notVeryActive
            case 250..<500:
                activityLevel = .lightlyActive
            case 500..<750:
                activityLevel = .active
            default:
                activityLevel = .veryActive
            }
            
        self.selectedActivity = activityItems.first { $0.title == activityLevel.localizedTitle }
        }
}
    
