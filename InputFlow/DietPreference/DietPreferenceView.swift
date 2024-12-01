//
//  DietPreferenceView.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//

import SwiftUI

struct DietPreferenceView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DietPreferenceVM()
    @State private var selectedDietPreference: DietPreferenceItem?
    
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            
            VStack(spacing: 15) {
                DGTitle(
                    title: "Diet Preference",
                    subtitle: "Please select your diet preference",
                    bottomPadding: 0)
                .padding(.leading, 20)
                ScrollView {
                    ZStack {
                        VStack(spacing: -1) {
                            ForEach(viewModel.dietPreferenceItems, id: \.self) { preference in
                                DietPreferenceElement(dietPreference: preference,
                                                      isSelected: preference == selectedDietPreference)
                                .onTapGesture {
                                    selectedDietPreference = preference
                                }
                            }
                        }
                        if let normalPreference = viewModel.dietPreferenceItems.first, normalPreference.title == "Normal" {
                            VStack {
                                Text("Recommended")
                                    .font(.montserrat(.medium, size: 8))
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.mkPurple)
                                            .frame(width: 90, height: 15)
                                    )
                                Spacer()
                            }
                            .offset(y: -5)
                        }
                    }
                    .padding(.top, 20)
                }
                Spacer()
                DGButton(text: "Next", backgroundColor: .mkOrange) {
                    viewModel.showIndicator = true
                    ProfileManager.shared.setUserDietPreference(selectedDietPreference?.title ?? "")
                    viewModel.goToHowActiveView = true
                }
                .conditionalOpacityAndDisable(isEnabled: selectedDietPreference != nil)
                
            }
            .navigationDestination(isPresented: $viewModel.goToHowActiveView) {
                HowActiveYouView()
            }
        }
               .navigationBarBackButtonHidden()
               .navigationBarItems(
                leading:
                    DGBackButton(),
                trailing:
                    HStack {
                        DGProgressBar(progressCount: Constant.progressCount, currentProgress: 2, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                        Spacer()
                            .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                    }
               )
    }
}

#Preview {
    DietPreferenceView()
}
