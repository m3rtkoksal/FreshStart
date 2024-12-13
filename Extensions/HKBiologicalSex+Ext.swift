//
//  HKBiologicalSex+Ext.swift
//  FreshStart
//
//  Created by Mert Köksal on 12.12.2024.
//

import HealthKit

extension HKBiologicalSex {
    func toLocalizedString() -> String {
        switch self {
        case .male:
            return "male".localized()
        case .female:
            return "female".localized()
        case .other:
            return "other".localized()
        case .notSet:
            return "not_set".localized()
        @unknown default:
            return "unknown".localized()
        }
    }
}
