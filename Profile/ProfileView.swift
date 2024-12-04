//
//  ProfileView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import HealthKit
import FirebaseAuth
import UserNotifications
import MessageUI
import StoreKit

struct ProfileView: View {
    @State private var showDeleteAlert = false
    @State private var deleteConfirmation = false
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.profile.rawValue
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var emailValidator = DefaultTextValidator(predicate: ValidatorHelper.emailPredicate)
    @StateObject private var passwordValidator = DefaultTextValidator(predicate: ValidatorHelper.passwordPredicate)
    @StateObject private var viewModel = ProfileVM()
    @ObservedObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            ScrollView(showsIndicators: false) {
                VStack {
                    HStack(spacing: 10) {
                        Image("profileTab")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("Personal")
                            .font(.montserrat(.semiBold, size: 18))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.leading, 20)
                    VStack {
                        FreshStartProfileElement(title: "User Type",
                                                 description: ProfileManager.shared.user.isPremium ?? false ? "Premium" : "Free",
                                                 buttonIcon: ProfileManager.shared.user.isPremium  ?? false ? "" : "basket.fill") {
                            withAnimation {
                                selectedTabRaw = MainTabView.Tab.offerings.rawValue
                            }
                        }
                        FreshStartProfileElement(title: "Username",
                                         description: ProfileManager.shared.user.userName ?? "",
                                         buttonIcon: "pencil") {
                            viewModel.goToChangeUsername = true
                        }
                        FreshStartProfileElement(title: "Name",
                                         description: ProfileManager.shared.user.firstName ?? "",
                                         buttonIcon: "pencil") {
                            viewModel.goToChangeFirstName = true
                        }
                        FreshStartProfileElement(title: "Surname",
                                         description: ProfileManager.shared.user.lastName ?? "",
                                         buttonIcon: "pencil") {
                            viewModel.goToChangeSurname = true
                        }
                        FreshStartProfileElement(title: "Birthday",
                                         description: ProfileManager.shared.user.birthday ?? "",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Email",
                                         description: ProfileManager.shared.user.email ?? "",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Gender",
                                         description: healthKitManager.hkBiologicalSexToGenderString(ProfileManager.shared.user.gender ?? HKBiologicalSex(rawValue: 3)!),
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Height",
                                         description: "\(Int((ProfileManager.shared.user.height ?? 0.0) * 100)) cm",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Weight",
                                         description: "\(Int((ProfileManager.shared.user.weight ?? 0.0))) kg",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Body Fat Percentage",
                                         description: "\(Int((ProfileManager.shared.user.bodyFatPercentage ?? 0.0) * 100)) %",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Lean Body Mass",
                                         description: "\(Int((ProfileManager.shared.user.leanBodyMass ?? 0.0))) kg",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Resting Energy",
                                         description: "\(Int((ProfileManager.shared.user.restingEnergy ?? 0.0))) kcal",
                                         buttonIcon: nil) { }
                        FreshStartProfileElement(title: "Active Energy",
                                         description: "\(Int((ProfileManager.shared.user.activeEnergy ?? 0.0))) kcal",
                                         buttonIcon: nil,
                                         isLastElement: true) { }
                    }
                }
                SubscriptionElement()
                    .padding(.vertical, -10)
                VStack {
                    HStack(spacing: 10) {
                        Image("generalMenuTitle")
                            .resizable()
                            .frame(width: 25, height: 25)
                        Text("General")
                            .font(.montserrat(.semiBold, size: 18))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(20)
                    VStack {
                        Divider()
                            .background(Color.black)
                        FreshStartProfileElement(title: "Notifications",
                                         description: "",
                                         buttonIcon: notificationIcon()) {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        FreshStartProfileElement(title: "Disclaimer & Data Privacy",
                                         description: "",
                                         buttonIcon: "chevron.compact.right") {
                            viewModel.goToResources = true
                        }
                        FreshStartProfileElement(title: "Contact support",
                                         description: "",
                                         buttonIcon: "chevron.compact.right") {
                            viewModel.goToContactSupport = true
                        }
                        FreshStartProfileElement(title: "Leave a review",
                                         description: "",
                                         buttonIcon: "chevron.compact.right",
                                         isLastElement: true) {
                            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                                SKStoreReviewController.requestReview(in: scene)
                            }
                        }
                        Divider()
                            .background(Color.black)
                    }
                    .padding(.top, -10)
                }
                HStack {
                    LogoutButton()
                    Spacer()
                    DeleteAccountButton(showDeleteAlert: $showDeleteAlert, deleteConfirmation: $deleteConfirmation)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
                
                .navigationDestination(isPresented: $viewModel.goToChangeFirstName) {
                    ChangeNameView(fieldType: .firstName)
                }
                .navigationDestination(isPresented: $viewModel.goToChangeSurname) {
                    ChangeNameView(fieldType: .surname)
                }
                .navigationDestination(isPresented: $viewModel.goToChangeUsername) {
                    ChangeNameView(fieldType: .username)
                }
                .navigationDestination(isPresented: $viewModel.goToResources) {
                    ResourcesView()
                }
                .sheet(isPresented: $viewModel.goToContactSupport) {
                    MailView(isShowing: $viewModel.goToContactSupport,
                             subject: "Support Request",
                             body: "Please describe your issue here.",
                             toRecipients: ["mertkoksal@mail.com"])
                }
            }
            .padding(.bottom, 50)
            .navigationBarBackButtonHidden(true)
            .fsAlertModifier(
                isPresented: $showDeleteAlert,
                title: "Confirm Account Deletion",
                message: "Are you sure you want to delete your account? This action cannot be undone.",
                confirmButtonText: "Delete",
                cancelButtonText: "Cancel",
                confirmAction: {
                    withAnimation {
                        showDeleteAlert = false
                        deleteConfirmation = true
                    }
                },
                cancelAction: {
                    showDeleteAlert = false
                }
            )
        }
    }
    
    private func notificationIcon() -> String {
        notificationManager.areNotificationsEnabled ? "bell.and.waves.left.and.right" : "bell.badge.slash.fill"
    }
}
