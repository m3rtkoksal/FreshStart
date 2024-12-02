//
//  FreshStartBaseView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

enum DGViewBackgroundType {
    case black
    case solidWhite
    case transparent
}

struct FreshStartBaseView<Content: View>: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    let currentViewModel: BaseViewModel
    @State private var isSuccess = true
    let background: DGViewBackgroundType
    let hideBackButton: Bool
    let content: Content
    @Binding var showIndicator: Bool
    
    init(
        currentViewModel: BaseViewModel,
        background: DGViewBackgroundType = .solidWhite,
        hideBackButton: Bool = false,
        showIndicator: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.currentViewModel = currentViewModel
        self.background = background
        self.hideBackButton = hideBackButton
        self.content = content()
        self._showIndicator = showIndicator
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            // Main Content
            content
                .disabled(showIndicator)
            
            // Loading Indicator
            if showIndicator {
                FreshStartLoadingView()
                    .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var backgroundColor: Color {
        switch background {
        case .black:
            return Color.black
        case .solidWhite:
            return Color.white
        case .transparent:
            return Color.clear
        }
    }
}
