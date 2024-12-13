//
//  WalkthroughCardView3.swift
//  FreshStart
//
//  Created by Mert Köksal on 22.11.2024.
//

import SwiftUI

struct WalkthroughCardView3: View {
    // MARK: - PROPERTIES
    let walkthrough: Walkthrough
    let onNext: () -> Void
    let isLastCard: Bool
    let walkthrough3ListData: [String] = [
        "walkthrough.lose_weight".localized(),
        "walkthrough.gain_muscle".localized(),
        "walkthrough.maintain_weight".localized(),
        "walkthrough.gain_weight".localized()
    ]
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading) {
            Text(walkthrough.title)
                .foregroundColor(Color.white)
                .font(.montserrat(.medium, size: 40))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.leading, 20)
            VStack {
                ForEach(walkthrough3ListData.indices, id: \.self) { index in
                    Walkthrough2ListElement(text: walkthrough3ListData[index])
                }
            }
            .padding(.top,40)
            .padding(.leading, 30)
            Text("walkthrough.ai_help".localized())
                .font(.montserrat(.regular, size: 20))
                .foregroundStyle(.white)
                .padding(.top,40)
                .padding(.leading, 30)
                .lineSpacing(5)
            Spacer()
            GeometryReader { geometry in
                ZStack {
                    Image("walkthrough3ImageSet")
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
