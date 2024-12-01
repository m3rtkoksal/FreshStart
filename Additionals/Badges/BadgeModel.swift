//
//  BadgeModel.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct BadgeModel: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    var isAchieved: Bool
    var achievementDate: Date?
    let criteria: String
    let color: Color
    
    init(
        id: UUID = UUID(),
        title: String = "",
        description: String = "",
        iconName: String = "",
        isAchieved: Bool = false,
        achievementDate: Date? = nil,
        criteria: String = "",
        color: Color = .mkOrange
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.iconName = iconName
        self.isAchieved = isAchieved
        self.achievementDate = achievementDate
        self.criteria = criteria
        self.color = color
    }
}
