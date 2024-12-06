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
                                .ignoresSafeArea(edges: .bottom)
                        }
                    }
                    .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
                }
                .navigationDestination(isPresented: $viewModel.goToDietProgram) {
                    withAnimation {
                        MainTabView()
                    }
                }
                .onAppear {
                    if !ProfileManager.shared.hasDietPlanBeenGenerated() {
                        viewModel.generateDietPlan { newDietPlan in
                            self.defaultDietPlan = newDietPlan
                            if let newId = newDietPlan?.id {
                                viewModel.saveDefaultPlanIdToFirestore(planId: newId)
                                ProfileManager.shared.setDefaultDietPlanId(newId)
                                let group = DispatchGroup()
                                var allSuccess = true
                                group.enter()
                                viewModel.fetchUsername { availableUsername in
                                    if !availableUsername {
                                        viewModel.generateAndSetUsername()
                                        allSuccess = false
                                    }
                                    group.leave()
                                }
                                group.enter()
                                viewModel.fetchAndUpdateMaxCounts { success in
                                    if !success {
                                        print("Failed to fetch or update max counts.")
                                        allSuccess = false
                                    }
                                    group.leave()
                                }
                                group.notify(queue: .main) {
                                    if allSuccess {
                                        viewModel.goToDietProgram = true
                                    } else {
                                        print("One or more Firestore operations failed. Navigation halted.")
                                        viewModel.showFailAlert = true
                                    }
                                }
                            } else {
                                print("Failed to generate a new diet plan ID.")
                                viewModel.showFailAlert = true
                            }
                        }
                        ProfileManager.shared.setDietPlanGenerated()
                    }
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
                                        viewModel.generateDietPlan { newDietPlan in
                                            self.defaultDietPlan = newDietPlan
                                            if let newId = newDietPlan?.id {
                                                viewModel.saveDefaultPlanIdToFirestore(planId: newId)
                                                ProfileManager.shared.setDefaultDietPlanId(newId)
                                                viewModel.goToDietProgram = true
                                            } else {
                                                
                                            }
                                        }
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
                                        viewModel.generateDietPlan { newDietPlan in
                                            self.defaultDietPlan = newDietPlan
                                            if let newId = newDietPlan?.id {
                                                viewModel.saveDefaultPlanIdToFirestore(planId: newId)
                                                ProfileManager.shared.setDefaultDietPlanId(newId)
                                                viewModel.showFailAlert = false
                                                viewModel.goToDietProgram = true
                                            } else {
                                                
                                            }
                                        }
                                    }
                                }
                               )
        }
       
    }
}

#Preview {
    LoadingView()
}
