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
                Image("FreshStartCircle")
                    .resizable()
                    .frame(width: 250, height: 102)
            }
            .padding(.trailing, 20)
            
            Spacer()
            
            GeometryReader { geometry in
                ZStack {
                    Image("walkthrough1ImageSet")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width)
                        .clipped()
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
