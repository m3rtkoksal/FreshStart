//
//  FrequencyView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FrequencyView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel = FrequencyVM()
    @State private var selectedFrequency: FrequencyItem?
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack(spacing:20) {
                FSTitle(
                    title: "how_many_meals_title".localized(),
                    subtitle: "how_many_meals_subtitle".localized(),
                    bottomPadding: 0
                )
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(viewModel.frequencyItems, id: \.self) { frequency in
                            FrequencyElement(
                                numberOfMeals: frequency.numberOfMeals,
                                subtitle: frequency.subtitle,
                                icons: frequency.icons,
                                isSelected: frequency == selectedFrequency) {
                                    selectedFrequency = frequency
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
                FreshStartButton(text: "next".localized(), backgroundColor: .mkOrange.opacity(0.9)) {
                    viewModel.showIndicator = true
                    ProfileManager.shared.setUserMealFrequency(selectedFrequency?.numberOfMeals ?? 0)
                    viewModel.goToAllergensView = true
                }
                .conditionalOpacityAndDisable(isEnabled: selectedFrequency != nil)
            }
            .navigationDestination(isPresented: $viewModel.goToAllergensView) {
                AllergensView()
            }
        }
               .navigationBarBackButtonHidden()
               .navigationBarItems(
                leading:
                    FreshStartBackButton(),
                trailing:
                    HStack {
                        FSProgressBar(progressCount: Constant.progressCount, currentProgress: 5, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
               )
               .onDisappear {
                   viewModel.showIndicator = false
               }
    }
}
#Preview {
    FrequencyView()
}
