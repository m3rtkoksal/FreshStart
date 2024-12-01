//
//  BadgeDetailView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct BadgeDetailView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = BadgesVM()
    var badge: BadgeModel
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mkPurple)
                .opacity(0.4)
                .frame(width: 80, height: 5)
                .padding(.top, 20)
            HStack(spacing: 20) {
                Text(badge.title)
                    .font(.montserrat(.bold, size: 20))
                    .foregroundColor(.black)
                    .padding(.leading, 5)
                Spacer()
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
            }
            .padding(20)
            VStack(spacing: 30) {
                Text("Criteria: \(badge.criteria)")
                    .font(.montserrat(.regular, size: 14))
                    .foregroundColor(.black)
                
                if let achievementDate = badge.achievementDate {
                    Text("Achieved on: \(achievementDate.getShortDate())")
                        .foregroundColor(.green)
                        .underline()
                        .font(.montserrat(.bold, size: 20))
                } else {
                    Text("Not Achieved Yet")
                        .font(.montserrat(.bold, size: 20))
                        .foregroundColor(.red)
                        .underline()
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}

#Preview {
    BadgeDetailView(badge: BadgeModel(
        title: "Top Fat Burner",
        description: "Awarded for burning the most fat this week.",
        iconName: "burn",
        isAchieved: false,
        achievementDate: nil,
        criteria: "Burn 2kg of fat in one week.",
        color: .buttonRed
    ))
}
