//
//  WalkthroughCardView.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.11.2024.
//

import SwiftUI

struct WalkthroughCardView1: View {
    // MARK: - PROPERTIES
    let walkthrough: Walkthrough
    let onNext: () -> Void
    let isLastCard: Bool
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(walkthrough.title)
                .foregroundColor(Color.white)
                .font(.montserrat(.medium, size: 40))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .frame(width: UIScreen.screenWidth * 0.7)
                .padding(.leading, 0)
            HStack {
                Spacer()
                ZStack {
                    Image("FreshStartCircle")
                        .resizable()
                    Text(walkthrough.headline ?? "")
                        .foregroundColor(Color.white)
                        .multilineTextAlignment(.center)
                        .font(.montserrat(.bold, size: 36))
                }
                .frame(width: 250, height: 102)
            }
            .padding(.trailing, 20)
            Spacer()
            ZStack {
                Image("walkthrough1ImageSet")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea(edges: .bottom)
            }
            .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
        }
    }
}
