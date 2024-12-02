//
//  PurposeInputView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct PurposeInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PurposeInputVM()
    @State private var selectedPurpose: PurposeItem?
    var body: some View {
        
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack(spacing: 20) {
                DGTitle(
                    title: "What’s your goal?",
                    subtitle: "Let’s focus on one goal to begin with.")
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(viewModel.purposeItems, id: \.self) { purpose in
                            PurposeElement(
                                title: purpose.title,
                                icon: purpose.icon,
                                isSelected: purpose == selectedPurpose)
                            .onTapGesture {
                                selectedPurpose = purpose
                            }
                        }
                    }
                }
                DGButton(text: "Next", backgroundColor: .mkOrange) {
                    viewModel.showIndicator = true
                    ProfileManager.shared.setUserCurrentPurpose(selectedPurpose?.title ?? "")
                    viewModel.goToFrequencyView = true
                }
                .conditionalOpacityAndDisable(isEnabled: selectedPurpose != nil)
            }
            .navigationDestination(isPresented: $viewModel.goToFrequencyView) {
                FrequencyView()
            }
            .onDisappear {
                self.viewModel.showIndicator = false
            }
        }
               .navigationBarBackButtonHidden()
               .navigationTitle("")
               .navigationBarItems(
                leading:
                    DGBackButton(),
                trailing:
                    HStack {
                        DGProgressBar(progressCount: Constant.progressCount, currentProgress: 4, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
               )
    }
}
