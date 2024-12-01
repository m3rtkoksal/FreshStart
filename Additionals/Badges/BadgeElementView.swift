//
//  BadgeElementView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct BadgeElementView: View {
    var badge: BadgeModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(badge.isAchieved ? badge.color : badge.color.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: badge.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(badge.isAchieved ? badge.color : badge.color.opacity(0.3))
                    )
            }
            .shadow(radius: badge.isAchieved ? 3 : 0)
            Spacer()
                .frame(height: 10)
            Text(badge.title)
                .font(.montserrat(.medium, size: 10))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .frame(width: 72)
            Spacer()
            if badge.isAchieved, let date = badge.achievementDate {
                Text(date.getShortDate())
                    .font(.montserrat(.regular, size: 8))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            } else {
                Text("")
                    .font(.montserrat(.regular, size: 8))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(5)
        .frame(width: 72, height: 120, alignment: .top)
        .padding(.vertical, 10)
    }
}

#Preview {
    HStack {
        let gridLayout = [GridItem(.fixed(100)), GridItem(.fixed(100))]
        LazyHGrid(rows: gridLayout, spacing: 10) {
            BadgeElementView(badge: BadgeModel(
                title: "Top Fat Burner",
                description: "Awarded for burning the most fat this week.",
                iconName: "flame.fill",
                isAchieved: true,
                achievementDate: Date(),
                criteria: "Burn 2kg of fat in one week."
            ))
            BadgeElementView(badge: BadgeModel(
                title: "Muscle Maker",
                description: "Awarded for gaining the most muscle this week.",
                iconName: "bolt.heart.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Gain 3kg of muscle in one week."
            ))
            BadgeElementView(badge: BadgeModel(
                title: "Consistency Hero",
                description: "Complete 7 days of tracking without skipping a day.",
                iconName: "calendar.badge.checkmark",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Track your meals and workouts daily for 7 days."
            ))
            BadgeElementView(badge:  BadgeModel(
                title: "Meal Master",
                description: "Create and save 10 unique recipes.",
                iconName: "fork.knife",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Generate 10 custom meal recipes."
            ))
            BadgeElementView(badge: BadgeModel(
                title: "Streak Saver",
                description: "Log activity every day for 30 days.",
                iconName: "clock.arrow.circlepath",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Complete a 30-day activity streak."
            ))
            BadgeElementView(badge: BadgeModel(
                title: "Healthy Starter",
                description: "Successfully complete your first diet plan.",
                iconName: "leaf.fill",
                isAchieved: true,
                achievementDate: Date(),
                criteria: "Follow a full diet plan for one week."
            ))
            BadgeElementView(badge: BadgeModel(
                title: "Protein Pioneer",
                description: "Achieve 150g of protein intake in a day.",
                iconName: "chart.bar.fill",
                isAchieved: false,
                achievementDate: nil,
                criteria: "Consume 150g or more protein in a single day."))
        }
    }
}
