//
//  MainTabView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = Tab.diary.rawValue
    @StateObject private var viewModel = MainTabVM()
    
    enum Tab: String {
        case diary
        case mealPlans
        case profile
        case additional
        case offerings
    }
    
    private var selectedTab: Tab {
        get { Tab(rawValue: selectedTabRaw) ?? .diary }
        set { selectedTabRaw = newValue.rawValue }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
                switch selectedTab {
                case .diary:
                    DiaryView()
                case .mealPlans:
                    SavedPlanView()
                case .additional:
                    AdditionalView()
                case .profile:
                    ProfileView()
                case .offerings:
                    OffersView()
                }
                
                HStack {
                    Spacer()
                        .frame(width: 35)
                    // Diary
                    Button(action: {
                        selectedTabRaw = Tab.diary.rawValue
                    }) {
                        VStack(spacing: 0) {
                            Image("diaryTab")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .opacity(selectedTab == .diary ? 1 : 0.3)
                            Text("Diary")
                                .font(.montserrat(.medium, size: 10))
                                .foregroundColor(selectedTab == .diary ? Color.black : .otherGray)
                        }
                    }
                    Spacer()
                        .frame(width: 35)
                    
                    // Meal Plans
                    Button(action: {
                        selectedTabRaw = Tab.mealPlans.rawValue
                    }) {
                        VStack(spacing: 0) {
                            Image("mealPlansTab")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .opacity(selectedTab == .mealPlans ? 1 : 0.3)
                            Text("Meal Plans")
                                .font(.montserrat(.medium, size: 10))
                                .foregroundColor(selectedTab == .mealPlans ? Color.black : .otherGray)
                        }
                    }
                    Spacer()
                    
                    // Additional
                    Button(action: {
                        selectedTabRaw = Tab.additional.rawValue
                    }) {
                        VStack(spacing: 0) {
                            Image("additionalTab")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .opacity(selectedTab == .additional ? 1 : 0.3)
                            Text("Additional")
                                .font(.montserrat(.medium, size: 10))
                                .foregroundColor(selectedTab == .additional ? Color.black : .otherGray)
                        }
                    }
                    
                    Spacer()
                        .frame(width: 35)
                    // Profile
                    Button(action: {
                        selectedTabRaw = Tab.profile.rawValue
                    }) {
                        VStack(spacing: 0) {
                            Image("profileTab")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .opacity(selectedTab == .profile ? 1 : 0.3)
                            Text("Profile")
                                .font(.montserrat(.medium, size: 10))
                                .foregroundColor(selectedTab == .profile ? Color.black : .otherGray)
                        }
                    }
                    Spacer()
                        .frame(width: 35)
                }
                .background(
                    Image("baseTabBar")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .ignoresSafeArea(edges: .bottom)
                        .opacity(0.85)
                        .frame(maxWidth: UIScreen.screenWidth, maxHeight: .infinity)
                )
                .overlay(
                    Button(action: {
                        selectedTabRaw = Tab.offerings.rawValue
                    }) {
                        ZStack {
                            Circle()
                                .frame(width: 56, height: 56)
                                .foregroundColor(.black)
                                .opacity(0.7)
                            Image("offeringsTab")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .offset(y: -40)
                    }
                )
            }
            .navigationBarHidden(true)
            .onAppear {
                AuthenticationManager.shared.logIn()
            }
    }
}
