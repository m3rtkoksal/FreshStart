//
//  DietPlanSheetView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import SwiftUI
import FirebaseAuth

struct DietPlanSheetView: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.mealPlans.rawValue
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var viewModel = SavedPlanViewModel()
    var dietPlan: DietPlan
    @Binding var shouldReload: Bool
    
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
                DeleteButtonView()
            }
        }
        .background(Color.white)
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
                    ProfileManager.shared.setDefaultDietPlan(dietPlan)
                    selectedTabRaw = MainTabView.Tab.diary.rawValue
                }
            },
            cancelAction: {
                viewModel.showChangeAlert = false
            }
        )
        .fsAlertModifier(
            isPresented: $viewModel.showDeleteAlert,
            title: "Confirm Diet Plan Delete",
            message: "Are you sure you want to delete this diet plan?",
            confirmButtonText: "Confirm",
            cancelButtonText: "Cancel",
            confirmAction: {
                withAnimation {
                    viewModel.showIndicator = true
                    viewModel.deleteDietPlanEntry(dietPlanId: dietPlan.id ?? "") { result in
                        switch result {
                        case .success:
                            viewModel.showIndicator = false
                            shouldReload = true
                            ProfileManager.shared.setDefaultDietPlanId("")
                            ProfileManager.shared.setDefaultDietPlan(DietPlan())
                            ProfileManager.shared.decrementDietPlanCount()
                            presentationMode.wrappedValue.dismiss()
                        case .failure(let error):
                            print("Error deleting diet plan: \(error.localizedDescription)")
                        }
                    }
                }
            },
            cancelAction: {
                viewModel.showDeleteAlert = false
            }
        )
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
            FreshStartButton(text: "Select This As My Diet Plan", backgroundColor: .mkPurple) {
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
    private func DeleteButtonView() -> some View {
        VStack(spacing: 10) {
            FreshStartButton(text: "Delete Plan", backgroundColor: .mkOrange, textColor: .black) {
                viewModel.showDeleteAlert = true
            }
        }
        .padding(.top, 10)
    }
}
