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
                Text("Prizes:")
                    .font(.montserrat(.bold, size: 14))
                Spacer()
            }
            .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 10) {
                PrizeExplanationList(rankText: "1st", prizeText: "7 days premium subscription")
                PrizeExplanationList(rankText: "2nd", prizeText: "5 days premium subscription")
                PrizeExplanationList(rankText: "3rd", prizeText: "3 days premium subscription")
                PrizeExplanationList(rankText: "4th", prizeText: "2 days premium subscription")
                PrizeExplanationList(rankText: "5th", prizeText: "1 day premium subscription")
            }
            .padding(.vertical)
            
            HStack {
                Text("Every Sunday at 00:00")
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
