//
//  RankElementView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct RankElementView: View {
    var userId: String
    var username: String
    var text: Double
    var selectedRankType: RankListType
    let rankIcon: String?
    let medalIcon: String?
    
    init(
        userId: String,
        username: String,
        text: Double,
        selectedRankType: RankListType,
        rankIcon: String? = nil,
        medalIcon: String? = nil
    ) {
        self.userId = userId
        self.username = username
        self.text = text
        self.selectedRankType = selectedRankType
        self.rankIcon = rankIcon
        self.medalIcon = medalIcon
    }
    var rankTypeString: String {
        switch selectedRankType {
        case .bodyFat:
            return "body_fat".localized()
        case .muscleMass:
            return "muscle_mass".localized()
        case .dailyLogin:
            return "daily_login".localized()
        }
    }
    var formattedText: String {
        switch selectedRankType {
        case .dailyLogin:
            return String(format: "%.0f", text)
        default:
            return String(format: "%.2f", text)
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: rankIcon ?? "")
                    .foregroundColor(.black)
                Image(medalIcon ?? "")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 30)
                Text(username.isEmpty ? userId : username)
                    .font(.montserrat(.medium, size: 14))
                    .frame(width: 110, alignment: .leading)
                    .padding(.leading, 5)
                Spacer()
                HStack(spacing: 2) {
                    Text(formattedText)
                        .font(.montserrat(.medium, size: 14))
                    if selectedRankType == .muscleMass {
                        Text("kg")
                            .font(.montserrat(.medium, size: 14))
                    }
                }
                .frame(width: 80, alignment: .trailing)
            }
            .padding(.leading, 20)
            .padding(.trailing, 60)
            .padding(.top, -15)
            Divider()
                .frame(height: 0.5)
                .background(Color.gray)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
