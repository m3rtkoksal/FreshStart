//
//  LoadingView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LoadingView: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.mealPlans.rawValue
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = LoadingVM()
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject var openAIManager = OpenAIManager.shared
    private let db = Firestore.firestore()
    @State var defaultDietPlan: DietPlan?
    
    var body: some View {
        NavigationStack {
            FreshStartBaseView(currentViewModel: viewModel,
                               background: .black,
                               showIndicator: $viewModel.showIndicator) {
                VStack {
                    FSTitle(
                        title: "creating_your_diet_plan".localized(),
                        subtitle: "\( "customizing_your_experience".localized() )\n\n\( "analyzing_health_data".localized() )\n\n\( "adding_your_goal".localized() )\n\n",
                        color: .white
                    )
                    Spacer()
                    ZStack {
                        if !openAIManager.showAlert {
                            LottieView(lottieFile: "FreshStartLoading", loopMode: .loop)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .scaleEffect(1.2)
                                .clipped()
                                .ignoresSafeArea(.all)
                                .offset(y: 60)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .navigationDestination(isPresented: $viewModel.goToDietProgram) {
                    withAnimation {
                        MainTabView()
                            .onAppear {
                                ProfileManager.shared.resetDietPlanGeneration()
                            }
                    }
                }
                .onAppear {
                    generateDietPlanAndFetchData()
                }
            }
                               .navigationTitle("")
                               .navigationBarBackButtonHidden()
                               .fsAlertModifier(
                                   isPresented: $openAIManager.showAlert,
                                   title: "timeout".localized(),
                                   message: "something_went_wrong".localized(),
                                   confirmButtonText: "retry".localized(),
                                   confirmAction: {
                                       withAnimation {
                                           generateDietPlanAndFetchData()
                                       }
                                   }
                               )
                               .fsAlertModifier(
                                isPresented: $viewModel.showFailAlert,
                                title: "timeout".localized(),
                                message: "something_went_wrong".localized(),
                                confirmButtonText: "retry".localized(),
                                confirmAction: {
                                    withAnimation {
                                        generateDietPlanAndFetchData()
                                    }
                                }
                               )
                               .fsAlertModifier(
                                isPresented: $viewModel.showDietPlanGenerationAlert,
                                title: "diet_plan_already_generated".localized(),
                                message: "one_diet_plan_at_a_time".localized(),
                                confirmButtonText: "ok".localized(),
                                confirmAction: {
                                    withAnimation {
                                        selectedTabRaw = MainTabView.Tab.mealPlans.rawValue
                                    }
                                }
                               )
        }
    }
    
    func generateDietPlanAndFetchData() {
        if ProfileManager.shared.hasDietPlanBeenGenerated() {
            viewModel.showDietPlanGenerationAlert = true
            return
        }
        let timeout: TimeInterval = 9
        
        // Start the timeout timer
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            if !viewModel.goToDietProgram {
                viewModel.showFailAlert = true
                ProfileManager.shared.resetDietPlanGeneration()
            }
        }
        viewModel.generateDietPlan { newDietPlan in
            self.defaultDietPlan = newDietPlan
            if let newId = newDietPlan?.id {
                viewModel.saveDefaultPlanIdToFirestore(planId: newId)
                ProfileManager.shared.setDefaultDietPlanId(newId)
                
                let group = DispatchGroup()
                var allSuccess = true
                
                // First task: fetch username
                group.enter()
                viewModel.fetchUsername { availableUsername in
                    if !availableUsername {
                        viewModel.generateAndSetUsername()
                        allSuccess = false
                    }
                    group.leave()
                }
                
                // Second task: fetch and update max counts
                group.enter()
                viewModel.fetchAndUpdateMaxCounts { success in
                    if !success {
                        print("Failed to fetch or update max counts.")
                        allSuccess = false
                    }
                    group.leave()
                }
                
                // After both tasks are completed
                group.notify(queue: .main) {
                    if allSuccess {
                        viewModel.goToDietProgram = true
                        ProfileManager.shared.incrementDietPlanCount()
                    } else {
                        print("One or more Firestore operations failed. Navigation halted.")
                        viewModel.showFailAlert = true
                        ProfileManager.shared.resetDietPlanGeneration()
                    }
                }
            } else {
                print("Failed to generate a new diet plan ID.")
                viewModel.showFailAlert = true
                ProfileManager.shared.resetDietPlanGeneration()
            }
        }
        ProfileManager.shared.setDietPlanGenerated()
    }
}

#Preview {
    LoadingView()
}
