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
        "Lose weight",
        "Gain muscle",
        "Maintain weight",
        "Gain weight"
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
            Text("With the help of AI we will create a perfect diet plan that will help you to achieve your goal!")
                .font(.montserrat(.regular, size: 20))
                .foregroundStyle(.white)
                .padding(.top,40)
                .padding(.leading, 30)
                .lineSpacing(5)
            Spacer()
            ZStack {
                Image("walkthrough3ImageSet")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
        }
    }
}