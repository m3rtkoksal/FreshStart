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
        DGView(currentViewModel: viewModel,
               background: .black,
               showIndicator: $viewModel.showIndicator) {
            
            NavigationStack {
                VStack {
                    DGTitle(
                        title: "Creating your diet plan",
                        subtitle: " Customizing your experience...  \n\n Analyzing your health data... \n\n Adding your goal... \n\n",
                        color: .white)
                    Spacer()
                    ZStack {
                        if !openAIManager.showAlert {
                            LottieView(lottieFile: "FreshStartLoading", loopMode: .loop)
                        }
                    }
                    .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
                    
                }
                .navigationDestination(isPresented: $viewModel.goToDietProgram) {
                    MainTabView()
                }
            }
            
            .onAppear {
                // Check if diet plan has been generated
                if !ProfileManager.shared.hasDietPlanBeenGenerated() {
                    viewModel.generateDietPlan { newDietPlan in
                        self.defaultDietPlan = newDietPlan
                        if let newId = newDietPlan?.id {
                            viewModel.saveDefaultPlanIdToFirestore(planId: newId)
                            ProfileManager.shared.setDefaultDietPlanId(newId)
                            let group = DispatchGroup()
                            var allSuccess = true
                            group.enter()
                            viewModel.fetchMaxCountFromFirestore { success in
                                if !success {
                                    print("Failed to fetch max counts.")
                                    allSuccess = false
                                }
                                group.leave()
                            }
                            group.enter()
                            viewModel.updateMaxPlanCountFirestore { success in
                                if !success {
                                    print("Failed to update maxPlanCount.")
                                    allSuccess = false
                                }
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                if allSuccess {
                                    viewModel.goToDietProgram = true
                                } else {
                                    print("One or more Firestore operations failed. Navigation halted.")
                                }
                            }
                        } else {
                            print("Failed to generate a new diet plan ID.")
                        }
                    }
                    ProfileManager.shared.setDietPlanGenerated()
                }
            }
        }
               .navigationTitle("")
               .navigationBarBackButtonHidden()
               .alert(isPresented: $openAIManager.showAlert) {
                   Alert(
                    title: Text("Timeout"),
                    message: Text(openAIManager.alertMessage),
                    primaryButton: .default(Text("Retry")) {
                        viewModel.generateDietPlan { newDietPlan in
                            self.defaultDietPlan = newDietPlan
                            if let newId = newDietPlan?.id {
                                viewModel.saveDefaultPlanIdToFirestore(planId: newId)
                                ProfileManager.shared.setDefaultDietPlanId(newId)
                                viewModel.goToDietProgram = true
                            } else {
                                
                            }
                        }
                    },
                    secondaryButton: .cancel() {
                        self.dismiss()
                    }
                   )
               }
    }
}

#Preview {
    LoadingView()
}