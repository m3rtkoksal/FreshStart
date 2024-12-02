//
//  FSProgressBar.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FSProgressBar: View {
    let progressCount: Int
    let currentProgress: Int
    var color: Color = .mkOrange
    var dotColor: Color = .white
    
    var body: some View {
        HStack(spacing: 6) {
            Capsule()
                .fill(color)
                .frame(width: capsuleWidth, height: 8)
                .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 4)
            
            ForEach(1...progressCount-1, id: \.self) { index in
                if index > currentProgress {
                    // Hide circles beyond current progress
                    Circle()
                        .fill(dotColor)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
    
    private func progressCircle(for index: Int) -> some View {
        Circle()
            .fill(progressColor(for: index))
            .frame(width: 8, height: 8)
            .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 4)
            .animation(.default, value: currentProgress)
    }
    
    private func progressColor(for index: Int) -> Color {
        index <= currentProgress ? Color.mkOrange : Color.white
    }
    
    private var capsuleWidth: CGFloat {
        // Initially 50, and then extend to the next circle on each progress
        let circleWidth: CGFloat = 8
        let spaceBetweenCircles: CGFloat = 6 // Space between circles

        // Width of the capsule, increasing for each progress step
        return 50 + (CGFloat(currentProgress) * (circleWidth + spaceBetweenCircles))
    }
}

#Preview {
    FSProgressBar(progressCount: 4, currentProgress: 3)
}
