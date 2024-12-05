//
//  WalkthroughCardView2.swift
//  FreshStart
//
//  Created by Mert Köksal on 22.11.2024.
//

import SwiftUI

struct WalkthroughCardView2: View {
    // MARK: - PROPERTIES
    let walkthrough: Walkthrough
    let onNext: () -> Void
    let isLastCard: Bool
    let walkthrough2ListData: [String] = [
        "Track your diet, water intake",
        "Create healthy habits",
        "Shape your lifestyle goals",
        "Track your activity",
        "Customize your meals"
        ]
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text(walkthrough.title)
                .foregroundColor(Color.white)
                .font(.montserrat(.medium, size: 36))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .lineSpacing(10)
                .frame(width: UIScreen.screenWidth * 0.9)
                .padding(.leading, 0)
            VStack {
                ForEach(walkthrough2ListData.indices, id: \.self) { index in
                    Walkthrough2ListElement(text: walkthrough2ListData[index])
                }
            }
            .padding(.top,50)
            .padding(.leading, 30)
            Spacer()
            GeometryReader { geometry in
                ZStack {
                    Image("walkthrough2ImageSet")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width)
                        .clipped()
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
    }
}

struct Walkthrough2ListElement: View {
    var text: String
    var body: some View {
        HStack {
            Circle()
                .fill(Color.mkOrange)
                .frame(width: 10, height: 10)
            Text(text)
                .font(.montserrat(.medium, size: 20))
                .foregroundStyle(.white)
                .padding(.leading, 15)
            Spacer()
        }
    }
}
