//
//  FreshStartLoadingView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FreshStartLoadingView: View {
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            // Rotating Circle
            LottieView(lottieFile: "foodLottie", loopMode: .loop)
                .frame(width: 100, height: 100)
        }
    }
}

// Preview for the loading view
struct DGLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        FreshStartLoadingView()
    }
}
