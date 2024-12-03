//
//  DietPlanSheetView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DietPlanSheetView: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.mealPlans.rawValue
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel = SavedPlanViewModel()
    var dietPlan: DietPlan
    
    var body: some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.mkPurple)
                .opacity(0.4)
                .frame(width: 80, height: 5)
                .padding(.top, 20)
            ScrollView(showsIndicators: false) {
                HeaderView()
                MealsView()
                ChangeDefaultButtonView()
                    .fsAlertModifier(
                        isPresented: $viewModel.showChangeAlert,
                        title: "Confirm Diet Plan Change",
                        message: "Are you sure you want to change your default diet plan?",
                        confirmButtonText: "Confirm",
                        cancelButtonText: "Cancel",
                        confirmAction: {
                            withAnimation {
                                viewModel.saveDefaultPlanToFirestore(planId: dietPlan.id ?? "")
                                ProfileManager.shared.setDefaultDietPlanId(dietPlan.id ?? "")
                                selectedTabRaw = MainTabView.Tab.diary.rawValue
                            }
                        },
                        cancelAction: {
                            viewModel.showChangeAlert = false
                        }
                    )
            }
        }
    }
    func HeaderView() -> some View {
        HStack {
            Text(dietPlan.purpose ?? "")
                .font(.montserrat(.bold, size: 20))
            Spacer()
            Image(dietPlan.dietPreference?.iconName() ?? "")
                .resizable()
                .frame(width: 46, height: 46)
        }
        .padding(20)
    }
    
    func MealsView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(dietPlan.meals.indices, id: \.self) { index in
                MealCardPreviewElement(
                    meal: dietPlan.meals[index],
                    icon: viewModel.mealIcons[index]
                )
            }
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(dietPlan.createdAt?.getFormattedDate(format: "dd.MM.yyyy HH:mm") ?? "N/A")
        }
        .frame(maxWidth: UIScreen.screenWidth)
    }
    
    func ChangeDefaultButtonView() -> some View {
        VStack {
            FreshStartButton(text: "Select This As My Diet Plan", backgroundColor: .mkOrange) {
                viewModel.showChangeAlert = true
            }
            .conditionalOpacityAndDisable(isEnabled: (dietPlan.id ?? "") != (ProfileManager.shared.user.defaultDietPlanId ?? ""))
            .onAppear {
                print("dietPlan.id: \(dietPlan.id ?? "nil")")
                print("defaultDietPlanId: \(ProfileManager.shared.user.defaultDietPlanId ?? "nil")")
            }
           

        }
        .padding(.top, 30)
    }
}
