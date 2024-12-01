//
//  HowActiveYouVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

enum ActivityLevel: String, CaseIterable {
    case notVeryActive = "Not very active"
    case lightlyActive = "Lightly active"
    case active = "Active"
    case veryActive = "Very active"
    
    var description: String {
        switch self {
        case .notVeryActive:
            return "Spend most of the day sitting (e.g. desk job, bank teller)"
        case .lightlyActive:
            return "Spend a good part of the day on your feet (e.g. teacher, salesperson)"
        case .active:
            return "Spend a good part of the day doing some physical activity (e.g. waiter, postal carrier)"
        case .veryActive:
            return "Spend most of the day doing heavy physical activity (e.g. construction worker, carpenter)"
        }
    }
}

class HowActiveYouVM: BaseViewModel {
    @Published var goToPurpose = false
    @Published var activityItems: [ActivityItem] = []
    @Published var selectedActivity: ActivityItem?
    
    func fetchActivityItems() {
        self.activityItems = ActivityLevel.allCases.map { level in
            ActivityItem(title: level.rawValue, subtitle: level.description)
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
            
            self.selectedActivity = activityItems.first { $0.title == activityLevel.rawValue }
        }
}
    
