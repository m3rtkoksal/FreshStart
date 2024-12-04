//
//  SavedPlanView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SavedPlanView: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.mealPlans.rawValue
    @StateObject private var rewardManager = RewardManager.shared
    @StateObject private var viewModel = SavedPlanViewModel()
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var selectedDietPlan = DietPlan()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator
        ) {
            ZStack {
                ScrollView {
                    VStack {
                        FSTitle(
                            title: "Your Saved Diet Plans",
                            subtitle: "You can see details of your previous meal plans from this list",
                            bottomPadding: 0
                        )
                        Spacer()
                            .frame(height: 20)
                        
                        ForEach(viewModel.dietPlans) { dietPlan in
                            VStack(alignment: .leading) {
                                DiaryElement(
                                    date: dietPlan.createdAt?.getFormattedDate(format: "dd.MM.yyyy") ?? "N/A",
                                    purpose: dietPlan.purpose ?? "",
                                    purposeImage: dietPlan.dietPreference?.iconName() ?? "",
                                    kcal: dietPlan.totalNutrients?.kcal ?? 0,
                                    protein: dietPlan.totalNutrients?.protein ?? 0,
                                    carbohydrate: dietPlan.totalNutrients?.carbohydrate ?? 0,
                                    fat: dietPlan.totalNutrients?.fat ?? 0
                                )
                                .padding(.bottom, 20)
                                .onTapGesture {
                                    selectedDietPlan = dietPlan
                                    viewModel.showDietPlanPreview = true
                                }
                            }
                        }
                    }
                    VStack {
                        Spacer()
                        createRemainingPlansText()
                        
                        FreshStartButton(text: "Create New Plan", backgroundColor: .mkOrange) {
                            viewModel.goToCreateNewPlan = true
                        }
                        .padding(.bottom, 100)
                        .conditionalOpacityAndDisable(isEnabled: viewModel.dietPlans.count < viewModel.maxPlanCount
//                                                      &&
//                                                      ProfileManager.shared.user.isPremium == true &&
//                                                      ProfileManager.shared.user.subscriptionEndDate > Date()
                        )
                    }
                }
            }
            .navigationDestination(isPresented: $viewModel.goToCreateNewPlan) {
                HealthKitPermissionView()
            }
            .sheet(isPresented: $viewModel.showDietPlanPreview) {
                DietPlanSheetView(dietPlan: selectedDietPlan)
                    .presentationDetents([.fraction(0.9)])
            }
            .onAppear {
                viewModel.showIndicator = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    viewModel.fetchDietPlans()
                    viewModel.fetchMaxPlanCountFromFirestore()
                }
            }
            .navigationBarTitle("")
            .navigationBarBackButtonHidden()
            .navigationBarItems(
                leading: FreshStartBackButton()
            )
        }
    }
    
    func createRemainingPlansText() -> some View {
        if viewModel.maxPlanCount > viewModel.dietPlans.count {
            return AnyView(
                Text("You can create \(viewModel.maxPlanCount - viewModel.dietPlans.count) more")
                    .underline()
                    .padding(.bottom)
                    .font(.montserrat(.medium, size: 14))
                    .foregroundColor(.black)
                    .hiddenConditionally(isHidden: viewModel.showIndicator)
            )
        } else {
            return AnyView(
                VStack {
                    Text("You can watch an advertisement to create new plan")
                        .underline()
                        .padding()
                        .font(.montserrat(.medium, size: 14))
                        .foregroundColor(.black)
                        .hiddenConditionally(isHidden: viewModel.showIndicator)
                        .frame(alignment: .center)
                    FreshStartButton(text: "Watch Ad earn new plan", backgroundColor: .mkPurple) {
                        if let rootVC = UIApplication.shared.connectedScenes
                            .compactMap({ $0 as? UIWindowScene })
                            .flatMap({ $0.windows })
                            .first(where: { $0.isKeyWindow })?.rootViewController {
                            rewardManager.showAd(from: rootVC) {
                                viewModel.incrementMaxPlanCount()
                            }
                        }
                    }
                }
            )
        }
    }
}
