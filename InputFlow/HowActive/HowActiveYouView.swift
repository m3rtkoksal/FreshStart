//
//  HowActiveYouView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct HowActiveYouView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel = HowActiveYouVM()
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack(spacing:20) {
                FSTitle(
                    title: "how_active_title".localized(),
                    subtitle: "how_active_subtitle".localized(),
                    bottomPadding: 0
                )
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.activityItems, id: \.self) { activity in
                            ActivityElement(
                                title: activity.title,
                                subtitle: activity.subtitle,
                                isSelected: activity == viewModel.selectedActivity)
                            .onTapGesture {
                                viewModel.selectedActivity = activity
                            }
                        }
                    }
                    .padding(.top, 5)
                }
                .padding(.bottom)
                Spacer()
                FreshStartButton(text: "next".localized(), backgroundColor: .mkOrange) {
                    ProfileManager.shared.setUserActivity(viewModel.selectedActivity?.title ?? "")
                    viewModel.goToPurpose = true
                }
            }
            .navigationDestination(isPresented: $viewModel.goToPurpose) {
                PurposeInputView()
            }
            
            .onAppear {
                viewModel.fetchActivityItems()
                if let activeEnergy = ProfileManager.shared.user.activeEnergy {
                    viewModel.selectActivityBasedOnEnergy(activeEnergy: activeEnergy)
                }
            }
            .onDisappear {
                viewModel.showIndicator = false
            }
        }
               .navigationBarBackButtonHidden()
               .navigationBarItems(
                leading:
                    FreshStartBackButton(),
                trailing:
                    HStack {
                        FSProgressBar(progressCount: Constant.progressCount, currentProgress: 3, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
               )
    }
}
#Preview {
    HowActiveYouView()
}
