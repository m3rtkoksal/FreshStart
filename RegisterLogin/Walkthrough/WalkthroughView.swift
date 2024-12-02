//
//  WalkthroughView.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.11.2024.
//

import SwiftUI

struct WalkthroughView: View {
    // MARK: - PROPERTIES
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var currentCardIndex = 0
    var walkthroughs: [Walkthrough] = walkthroughData
    @State private var goToWelcomePage: Bool = false
    @State private var isAnimating: Bool = false
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    FSProgressBar(progressCount: walkthroughs.count, currentProgress: currentCardIndex)
                        .frame(width: 100, height: 30)
                        .padding(.trailing, 20)
                }
                TabView(selection: $currentCardIndex) {
                    ForEach(walkthroughs.indices, id: \.self) { index in
                        if index == 0 {
                            WalkthroughCardView1(
                                walkthrough: walkthroughs[index],
                                onNext: goToNextCard,
                                isLastCard: index == walkthroughs.count - 1).tag(index)
                        } else if index == 1 {
                            WalkthroughCardView2(
                                walkthrough: walkthroughs[index],
                                onNext: goToNextCard,
                                isLastCard: index == walkthroughs.count - 1).tag(index)
                        } else if index == 2 {
                            WalkthroughCardView3(
                                walkthrough: walkthroughs[index],
                                onNext: goToNextCard,
                                isLastCard: index == walkthroughs.count - 1).tag(index)
                        } else if index == 3 {
                            WalkthroughCardView4(
                                walkthrough: walkthroughs[index],
                                onNext: goToNextCard,
                                isLastCard: index == walkthroughs.count - 1).tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.all)
                .navigationDestination(isPresented: $goToWelcomePage) {
                    LoginView()
                }
            }
        }
    }
    
    private func goToNextCard() {
        if currentCardIndex < walkthroughs.count - 1 {
            currentCardIndex += 1
        } else {
            authManager.completeOnboarding()
            self.goToWelcomePage = true
        }
    }
}
