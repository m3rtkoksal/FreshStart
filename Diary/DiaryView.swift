//
//  DiaryView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DiaryView: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.diary.rawValue
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = DiaryVM()
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var selectedMeals: Set<Meal> = []
    private let mealManager = MealManager()
    @State var maxPlanCount: Int = 0
    @State var maxMealCount: Int = 0
    @State private var shouldRegenerateRecipe = false
    @State private var isHeaderVisible = true
    @State private var showIndicator = false
    @State private var scrollOffset: CGFloat = 0
    var edges = UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    @State private var isDataLoaded = false
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
                           background: .solidWhite,
                           showIndicator: $viewModel.showIndicator
        ) {
            if viewModel.showIndicator {
                FreshStartLoadingView()
            } else if ProfileManager.shared.user.defaultDietPlanId == nil {
                // No diet plan exists, show a placeholder or empty state view
                EmptyDietPlanView()
                    .onAppear {
                        viewModel.fetchMaxCountFromFirestore()
                    }
            } else {
                ZStack(alignment: .top, content: {
                    HeaderView()
                        .zIndex(1)
                        .offset(y: viewModel.headerOffset)
                    ScrollView(.vertical, showsIndicators: false, content : {
                        DietPlanSummary()
                            .background {
                                GeometryReader { proxy in
                                    // Retrieving the proxy value using PreferenceKey
                                    let minY = proxy.frame(in: .named("ScrollView")).minY
                                    DispatchQueue.main.async {
                                        if viewModel.startMinY == 0 {
                                            viewModel.startMinY = minY
                                        }
                                        let offset = viewModel.startMinY - minY
                                        if offset > viewModel.offset {
                                            viewModel.bottomScrollOffset = 0
                                            if viewModel.topScrollOffset == 0 {
                                                viewModel.topScrollOffset = offset
                                            }
                                            let progress = (viewModel.topScrollOffset + getMaxOffset()) - offset
                                            let offsetCondition = (viewModel.topScrollOffset + getMaxOffset()) >= getMaxOffset() && getMaxOffset() - progress <= getMaxOffset()
                                            let headerOffset = offsetCondition ? -(getMaxOffset() - progress) : -getMaxOffset()
                                            viewModel.headerOffset = headerOffset
                                        }
                                        if offset < viewModel.offset {
                                            viewModel.topScrollOffset = 0
                                            if viewModel.bottomScrollOffset == 0 {
                                                viewModel.bottomScrollOffset = offset
                                            }
                                            withAnimation(.easeOut(duration: 0.25)) {
                                                let headerOffset = viewModel.headerOffset
                                                viewModel.headerOffset = viewModel.bottomScrollOffset >= offset + 40 ? 0 : (headerOffset != -getMaxOffset() ? 0 : headerOffset)
                                            }
                                        }
                                        viewModel.offset = offset
                                    }
                                    return Color.clear
                                }
                                .frame(height: 0, alignment: .top)
                            }
                        NutrientChartExplainText()
                        SubscriptionElement()
                        InfoCardElement()
                        MealsView(selectedMeals: $selectedMeals)
                        DeleteButtonView()
                        WaterTrackView()
                        Spacer()
                            .frame(height: 90)
                    })
                    .coordinateSpace(name: "ScrollView")
                })
                .onAppear {
                    guard !isDataLoaded else { return }
                    isDataLoaded = true
                    viewModel.fetchMaxCountFromFirestore()
                    if let cachedDietPlan = ProfileManager.shared.user.defaultDietPlan {
                        viewModel.dietPlan = cachedDietPlan
                        print("Using cached diet plan: \(cachedDietPlan)")
                        processDietPlan(cachedDietPlan)
                        viewModel.showIndicator = false
                    } else {
                        viewModel.fetchDietPlan { dietPlan in
                            if let dietPlan = dietPlan {
                                ProfileManager.shared.setDefaultDietPlan(dietPlan)
                                viewModel.dietPlan = dietPlan
                                print("Diet plan fetched: \(dietPlan)")
                                processDietPlan(dietPlan)
                            } else {
                                print("No diet plan found")
                            }
                            viewModel.showIndicator = false
                        }
                    }
                }
                
                .onDisappear {
                    if let dietPlanId = viewModel.dietPlan.id, !dietPlanId.isEmpty {
                        MealManager.shared.saveSelectedMeals(dietPlanId: dietPlanId, selectedMeals: selectedMeals)
                    } else {
                    }
                }
                .onChange(of: viewModel.dietPlan) { newDietPlan in
                    // Trigger action when `lastDietPlan` changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        viewModel.dietPlan = newDietPlan
                        processDietPlan(newDietPlan)
                    }
                }
                .onChange(of: ProfileManager.shared.user.defaultDietPlan) { newDietPlan in
                    if let newDietPlan = newDietPlan {
                        viewModel.dietPlan = newDietPlan
                        print("Updated diet plan: \(newDietPlan)")
                        processDietPlan(newDietPlan)
                    }
                }
            }
        }
    }
    private func processDietPlan(_ dietPlan: DietPlan) {
        MealManager.shared.checkAndCleanDaily()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let dietPlanId = dietPlan.id, !dietPlanId.isEmpty {
                // Load selected meals only once on appear
                selectedMeals = MealManager.shared.loadSelectedMeals(dietPlanId: dietPlanId)
                viewModel.showIndicator = false
            } else {
                viewModel.showIndicator = false
            }
        }
    }
    
    private func getMaxOffset() -> CGFloat {
        return viewModel.startMinY + edges.top + 10
    }
    
    func DietPlanSummary() -> some View {
        HStack {
            StepsView()
            Spacer()
            if let totalNutrients = viewModel.calculateTotalNutrients(selectedMeals: selectedMeals) {
                DonutChartView(totalNutrients: totalNutrients)
            }
        }
        .padding(.top, 100)
        .padding(.horizontal, 40)
        .frame(maxWidth: UIScreen.screenWidth)
    }
    
    func HeaderView() -> some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    Text("My goal is to")
                        .font(.montserrat(.medium, size: 14))
                    Text(viewModel.dietPlan.purpose ?? "")
                        .font(.montserrat(.bold, size: 24))
                }
                .foregroundColor(.black)
                .padding(.leading, 20)
                .padding(.bottom, 25)
                Spacer()
                VStack(alignment: .center) {
                    HStack(spacing: 10) {
                        Image(systemName: "calendar")
                        Text(viewModel.dietPlan.createdAt?.getShortDate() ?? "N/A")
                            .font(.montserrat(.semiBold, size: 12))
                    }
                    .underline()
                }
                .padding(.trailing, 20)
                .foregroundColor(.black)
            }
        }
        .frame(width: UIScreen.screenWidth, height: 143, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 40)
                .fill(Color.mkPurple.opacity(0.5))
        )
        .ignoresSafeArea(edges: .top)
    }
    
    private func DeleteButtonView() -> some View {
        VStack(spacing: 10) {
            FreshStartButton(text: "Delete Plan", backgroundColor: .mkOrange, textColor: .black) {
                viewModel.showIndicator = true
                viewModel.deleteDietPlanEntry(dietPlan: viewModel.dietPlan) { result in
                    viewModel.showIndicator = false
                    switch result {
                    case .success:
                        if let userId = Auth.auth().currentUser?.uid {
                            viewModel.updateMaxPlanCountInFirestore(userId: userId, maxPlanCount: viewModel.maxPlanCount)
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    case .failure(let error):
                        print("Error deleting diet plan: \(error.localizedDescription)")
                    }
                }
            }
        }
        .padding(.top, 20)
    }
    
    func createRemainingPlansText() -> some View {
        Group {
            if viewModel.maxPlanCount > ProfileManager.shared.user.dietPlanCount ?? 0 {
                Text("You can create \(viewModel.maxPlanCount - (ProfileManager.shared.user.dietPlanCount ?? 0)) more")
                    .underline()
                    .padding(.bottom)
                    .font(.montserrat(.medium, size: 14))
                    .foregroundColor(.black)
                    .hiddenConditionally(isHidden: viewModel.showIndicator)
            } else {
                Text("You can watch an advertisement to create new plan")
                    .underline()
                    .padding(.bottom)
                    .font(.montserrat(.medium, size: 14))
                    .foregroundColor(.black)
                    .hiddenConditionally(isHidden: viewModel.showIndicator)
            }
        }
        .background(Color.clear)
    }
    
    private func EmptyDietPlanView() -> some View {
        VStack {
            FSTitle(
                title: "Purchase Your First Diet Plan",
                subtitle: "You currently do not have any diet plans.")
            ScrollView {
                SubscriptionElement()
                    .padding(.top)
            }
            Spacer()
            createRemainingPlansText()
            FreshStartButton(text: "Create New Plan", backgroundColor: .mkOrange) {
                viewModel.goToCreateNewPlan = true
            }
            .padding(.bottom, 150)
            .conditionalOpacityAndDisable(
                isEnabled: ProfileManager.shared.user.dietPlanCount ?? 0 < viewModel.maxPlanCount)
        }
        .navigationDestination(isPresented: $viewModel.goToCreateNewPlan) {
            HealthKitPermissionView()
        }
    }
    
    private func MealsView(selectedMeals: Binding<Set<Meal>>) -> some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.dietPlan.meals.indices, id: \.self) { index in
                MealCardElementView(
                    meal: viewModel.dietPlan.meals[index],
                    icon: viewModel.mealIcons[index],
                    selectedMeals: selectedMeals.wrappedValue
                )
                .onTapGesture {
                    let meal = viewModel.dietPlan.meals[index]
                    
                    if selectedMeals.wrappedValue.contains(meal) {
                        selectedMeals.wrappedValue.remove(meal)
                    } else {
                        selectedMeals.wrappedValue.insert(meal)
                    }
                    notificationManager.startInactivityTimer()
                    notificationManager.checkForgotToSelectReminder()
                }
                .overlay(
                    VStack {
                        Spacer()
                        HStack(spacing: 0) {
                            ReCreateMealButton(viewModel: self.viewModel,
                                               dietPlanId: viewModel.dietPlan.id ?? "",
                                               meal: $viewModel.dietPlan.meals[index],
                                               shouldRegenerateRecipe: $shouldRegenerateRecipe,
                                               index: index)
                            Divider()
                                .frame(width: 1, height: 35)
                                .background(Color.black)
                            CreateRecipeButton(dietPlanId: viewModel.dietPlan.id ?? "",
                                               meal: viewModel.dietPlan.meals[index],
                                               index: index,
                                               shouldRegenerateRecipe: $shouldRegenerateRecipe)
                        }
                        .padding(.bottom, 10)
                    }
                )
            }
            .padding(.top)
            .navigationBarBackButtonHidden()
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.dietPlan.createdAt?.getFormattedDate(format: "dd.MM.yyyy HH:mm") ?? "N/A")
            .navigationBarItems(
                leading:
                    FreshStartBackButton()
            )
            Link("Learn more about diet and nutrition", destination: URL(string: "https://www.niddk.nih.gov/health-information/diet-nutrition")!)
                .font(.montserrat(.medium, size: 14))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .foregroundColor(.mkPurple)
                .padding(.top, 10)
        }
        .frame(maxWidth: UIScreen.screenWidth)
    }
}

struct InfoCardElement: View {
    var body:some View {
        HStack {
            Text("Tap “+” to mark your meal as eaten. Selected meals will reset each night automatically.")
                .font(.montserrat(.medium, size: 14))
            Spacer()
        }
        .padding(.leading, 20)
        .padding(.trailing, 50)
        .padding(.top, 30)
        .padding(.bottom, -20)
    }
}

struct NutrientChartExplainText: View {
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 30)
            HStack(spacing: 15) {
                Spacer()
                NutrientChartText(color: .black, text: "Protein")
                NutrientChartText(color: .mkOrange, text: "Carbohydrate")
                NutrientChartText(color: .mkPurple, text: "Fat")
            }
        }
        .padding(.trailing, 20)
    }
}

struct WaterTrackView: View {
    @State private var waterIntake: Int = {
        let latestEntry = MealManager.shared.loadWaterEntries().last
        return latestEntry?.waterIntake ?? 0
    }()
    @State private var filledGlasses: Int = MealManager.shared.loadFilledGlasses()
    var body: some View {
        Button {
            if filledGlasses < 8 {
                waterIntake += 250
                filledGlasses += 1
                MealManager.shared.saveWaterData(waterIntake: waterIntake, filledGlasses: filledGlasses)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .foregroundColor(Color.mkPurple)
                    .frame(width: UIScreen.screenWidth - 40, height: 160)
                    .overlay(
                        VStack {
                            HStack{
                                Text("Water")
                                    .font(.montserrat(.semiBold, size: 18))
                                    .foregroundColor(.white)
                                    .underline()
                                Spacer()
                                Text("\(waterIntake / 1000).\(waterIntake % 1000 / 100)L / 2L")
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 30)
                            HStack {
                                ForEach(0..<8){ index in
                                    Image("glassWater")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .opacity(index < filledGlasses ? 1 : 0.3)
                                }
                            }
                            .padding(.horizontal, 40)
                            HStack{
                                Spacer()
                                Text("Remember to stay hydrated!")
                                    .font(.montserrat(.medium, size: 12))
                                    .foregroundColor(.white)
                                Image("infoWater")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 25)
                        }
                            .padding(.vertical,20)
                    )
            }
        }
        .padding(.vertical, 50)
    }
}
