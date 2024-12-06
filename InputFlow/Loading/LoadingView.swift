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
                        title: "Creating your diet plan",
                        subtitle: " Customizing your experience...  \n\n Analyzing your health data... \n\n Adding your goal... \n\n",
                        color: .white)
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
                                title: "Timeout",
                                message: "Something went wrong.",
                                confirmButtonText: "Retry",
                                confirmAction: {
                                    withAnimation {
                                        generateDietPlanAndFetchData()
                                    }
                                }
                               )
                               .fsAlertModifier(
                                isPresented: $viewModel.showFailAlert,
                                title: "Timeout",
                                message: "Something went wrong.",
                                confirmButtonText: "Retry",
                                confirmAction: {
                                    withAnimation {
                                        generateDietPlanAndFetchData()
                                    }
                                }
                               )
                               .fsAlertModifier(
                                isPresented: $viewModel.showDietPlanGenerationAlert,
                                title: "Diet Plan Already Generated",
                                message: "You can only generate one diet plan at a time. Please wait before trying again.",
                                confirmButtonText: "OK",
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
