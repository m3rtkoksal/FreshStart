//
//  DGView.swift
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

struct DGView<Content: View>: View {
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
            
            // Loading Indicator
            if showIndicator {
                DGLoadingView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var backgroundColor: Color {
        switch background {
        case .black:
            return Color.black
        case .solidWhite:
            return Color.solidWhite
        case .transparent:
            return Color.clear
        }
    }
}
