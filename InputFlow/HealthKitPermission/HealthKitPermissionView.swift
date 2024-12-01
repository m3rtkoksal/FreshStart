//
//  HealthKitPermissionView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

struct HealthKitPermissionView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var healthKitManager = HealthKitManager.shared
    @StateObject private var viewModel = HealthKitPermissionVM()
    @State private var showAlert = false
    @State private var isOn: Bool = false
    @State private var hasCheckedAuthorization = false
    @State private var activeAlert: AlertType?
    @State private var isDataLoaded = false
    private let db = Firestore.firestore()
    
    func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            self.checkHealthKitAuthorization()
            isOn = healthKitManager.isAuthorized
        case .active:
            // Check authorization when the app becomes active
            self.checkHealthKitAuthorization()
            isOn = healthKitManager.isAuthorized
        default:
            break
        }
    }
    
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
                 showIndicator: $viewModel.showIndicator) {
                VStack {
                    DGTitle(
                        title: "Health Data",
                        subtitle: "",
                        bottomPadding: 20)
                    VStack(spacing: 40) {
                        Text("FreshStart uses your calorie intake, fitness activities, height and weight, and other health related data to provide you with our customized services. \n\n The core features of FreshStart can't function without such data. If you don't agree, you won't be able to use the app.")
                            .foregroundColor(.black)
                            .font(.montserrat(.medium, size: 14))
                            .padding(.horizontal,20)
                            .padding(.top,10)
                            .fixedSize(horizontal: false, vertical: true)
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                            HStack {
                                Image("health")
                                    .foregroundColor(.red)
                                Text("Export Data From Apple Health")
                                    .foregroundColor(.black)
                                    .font(.montserrat(.bold, size: 14))
                                    .multilineTextAlignment(.leading)
                                    .frame(width: UIScreen.screenWidth * 0.34)
                                Spacer()
                                Toggle("", isOn: $isOn)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: isOn ? Color.mkPurple.opacity(1) : Color.mkPurple.opacity(0.5)))
                                    .onChange(of: isOn) { newValue in
                                        if newValue == false {
                                            if healthKitManager.isAuthorized {
                                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                                    viewModel.goToBMIInputPage = false
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                }
                                            }
                                        } else {
                                            // Request authorization asynchronously
                                            healthKitManager.requestAuthorization { success in
                                                DispatchQueue.main.async {
                                                    if success && healthKitManager.isAuthorized {
                                                        isOn = true
                                                        viewModel.showIndicator = true
                                                        self.saveHealthDataToUserInputModel {
                                                            self.isDataLoaded = true
                                                            viewModel.showIndicator = false
                                                            viewModel.goToBMIInputPage = true
                                                        }
                                                    } else {
                                                        isOn = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                
                                    .onChange(of: healthKitManager.isAuthorized) { newValue in
                                        isOn = newValue
                                    }
                                    .onAppear {
                                        isOn = healthKitManager.isAuthorized
                                    }
                            }
                        }
                        .frame(height: 73)
                        .padding()
                        .frame(maxWidth: UIScreen.screenWidth / 1.2)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(lineWidth: 1)
                        )
                        .padding(.top)
                        DGDivider(title: "Or enter Manually")
                        Spacer()
                        DGButton(text: "Enter Manually", backgroundColor: .mkOrange) {
                            viewModel.goToBMIInputPage = true
                        }
                        Button(action: {
                            viewModel.goToPrivacyPolicy = true
                        }) {
                            VStack(alignment: .leading, spacing: 30) {
                                Text("By tapping 'Enter Manually', you agree to the processing of your health data.\n\n For more information have a look at our ")
                                    .font(.montserrat(.medium, size: 14)) +
                                Text("Privacy Policy.")
                                    .font(.montserrat(.bold, size: 14))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal,33)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .navigationDestination(isPresented: $viewModel.goToBMIInputPage) {
                        DetailsAboutMeView()
                    }
                    
                }
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarItems(
                                        leading:
                                            DGDismissButton(presentationMode: presentationMode)
                                    )
        }
                 .onChange(of: scenePhase, perform: handleScenePhaseChange)
    }
    
    private func checkHealthKitAuthorization() {
        // Perform the authorization check after a brief delay to allow isAuthorized to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !self.healthKitManager.isAuthorized {
                activeAlert = .authorizationRequired
            }
        }
    }
    
    func saveHealthDataToUserInputModel(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user ID found.")
            return
        }
        
        healthKitManager.fetchYearlyData(userId: userId) { activeEnergyData, restingEnergyData, bodyFatPercentageData, leanBodyMassData, weightData, genderData, heightData, birthdayData, heartRateData, hrvData, stressLevelData in
            ProfileManager.shared.setCustomerId(id: userId)
            
            let daysInYear = 365.0
            let dailyActiveEnergy = (activeEnergyData ?? 0.0) / daysInYear
            let dailyRestingEnergy = (restingEnergyData ?? 0.0) / daysInYear
            // Update user input model
            ProfileManager.shared.setUserActiveEnegry(dailyActiveEnergy)
            ProfileManager.shared.setUserRestingEnegry(dailyRestingEnergy)
            ProfileManager.shared.setUserBodyFatPercentage(bodyFatPercentageData ?? 0)
            ProfileManager.shared.setUserLeanBodyMass(leanBodyMassData ?? 0)
            ProfileManager.shared.setUserWeight(weightData ?? 0)
            ProfileManager.shared.setUserHeight(heightData ?? 0)
            if let gender = genderData {
                ProfileManager.shared.setUserGender(gender)
            }
            ProfileManager.shared.setUserBirthday(birthdayData ?? "")
            ProfileManager.shared.setUserHeartRate(heartRateData ?? 0.0)
            ProfileManager.shared.setUserHRV(hrvData ?? 0.0)
            ProfileManager.shared.setUserStressLevel(stressLevelData ?? "")
            completion()
        }
    }
}
