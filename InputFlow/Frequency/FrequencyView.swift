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
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack(spacing:20) {
                DGTitle(
                    title: "How many meals",
                    subtitle: "Select how many meals do you eat a day including snacks",
                    bottomPadding: 0)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 15) {
                        ForEach(viewModel.frequencyItems, id: \.self) { frequency in
                            FrequencyElement(
                                numberOfMeals: frequency.numberOfMeals,
                                subtitle: frequency.subtitle,
                                icons: frequency.icons,
                                isSelected: frequency == selectedFrequency
                            )
                            .onTapGesture {
                                selectedFrequency = frequency
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                DGButton(text: "Next", backgroundColor: .mkOrange.opacity(0.9)) {
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
                    DGBackButton(),
                trailing:
                    HStack {
                        DGProgressBar(progressCount: Constant.progressCount, currentProgress: 5, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
               )
    }
}
#Preview {
    FrequencyView()
}