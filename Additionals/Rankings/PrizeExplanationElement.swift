//
//  PrizeExplanationElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct PrizeExplanationElement: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("prizes".localized())
                    .font(.montserrat(.bold, size: 14))
                Spacer()
            }
            .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                PrizeExplanationList(rankText: "1st".localized(), prizeText: "7_days_premium".localized())
                PrizeExplanationList(rankText: "2nd".localized(), prizeText: "5_days_premium".localized())
                PrizeExplanationList(rankText: "3rd".localized(), prizeText: "3_days_premium".localized())
                PrizeExplanationList(rankText: "4th".localized(), prizeText: "2_days_premium".localized())
                PrizeExplanationList(rankText: "5th".localized(), prizeText: "1_day_premium".localized())
            }
            .padding(.vertical)
            
            HStack {
                Text("sunday_midnight".localized())
                    .font(.montserrat(.semiBold, size: 14))
                    .underline()
                Spacer()
            }
            .padding(.leading, 20)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mkPurple.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal, 20)
        )
    }
}

#Preview {
    PrizeExplanationElement()
}

struct PrizeExplanationList: View {
    var rankText: String = ""
    var prizeText: String = ""
    
    var body: some View {
        HStack {
            Text(rankText)
                .frame(width: 30, alignment: .leading)
                .font(.montserrat(.semiBold, size: 12))
            Text(prizeText)
                .font(.montserrat(.medium, size: 10))
        }
        .foregroundColor(.black)
        .font(.montserrat(.regular, size: 14))
    }
}
