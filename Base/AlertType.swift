//
//  AlertType.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

enum AlertType: Identifiable {
    case authorizationRequired
    case premiumAccountNeeded
    case noDietPlan
    
    var id: UUID {
        switch self {
        case .authorizationRequired:
            return UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        case .premiumAccountNeeded:
            return UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
        case .noDietPlan:
            return UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
        }
    }
}
