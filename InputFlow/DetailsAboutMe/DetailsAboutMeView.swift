//
//  DetailsAboutMeView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DetailsAboutMeView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var healthKitManager = HealthKitManager()
    @StateObject private var validationModel = ValidationModel()
    @State private var showDatePicker = false
    @State private var birthdayText: String = ""
    @State private var birthday: Date = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    @StateObject private var viewModel = DetailsAboutMeVM()
    @State private var selectedLengthItem = DGDropdownItemModel(id: "", text: "")
    @State private var selectedLengthUnit: LengthUnit = .cm
    @State private var selectedPurposeSegmentIndex = 0
    @State private var selectedGenderSegmentIndex = 0
    @State private var isDatePickerVisible = true
    @State private var isLengthExpanded = false
    @State private var isGenderExpanded = false
    @State private var selectedWeightItem = DGDropdownItemModel(id: "", text: "")
    @State private var selectedWeightUnit: WeightUnit = .kg
    @State private var isWeightExpanded = false
    @State private var selectedGenderItem = DGDropdownItemModel(id: "", text: "")
    @State private var goToDietPreference = false
    @State private var tempLength: Double? = nil
    @State private var tempWeight: Double? = nil
    var body: some View {
        ZStack {
            FreshStartBaseView(currentViewModel: viewModel,
                   background: .solidWhite,
                   showIndicator: $viewModel.showIndicator) {
                VStack {
                    DGTitle(
                        title: "Details About You",
                        subtitle: "FreshStart needs to know a bit about your physiology to create the most suitable plan for you.")
                    VStack(alignment: .leading, spacing: 0) {
                        DGDropdownField(
                            title: "Please select your gender",
                            isExpanded: $isGenderExpanded,
                            chosenItem: $selectedGenderItem)
                        .onTapGesture {
                            isGenderExpanded = true
                        }
                        ZStack {
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(width: UIScreen.screenWidth, height: 1)
                                    .background(Color.black)
                                Spacer()
                                    .frame(height: 14)
                                HStack {
                                    Text(birthdayText.isEmpty ? "Date of Birth" : birthdayText)
                                        .font(.montserrat(.medium, size: 14))
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 20)
                                        .frame(height: 22)
                                    Spacer()
                                }
                                Spacer()
                                    .frame(height: 14)
                            }
                            .disabled(true)
                            .background(Color.clear)
                            DatePickerView()
                        }
                        DGDropdownField(
                            title: "How tall are you?",
                            isExpanded: $isLengthExpanded,
                            chosenItem: $selectedLengthItem
                        )
                        .onTapGesture {
                            isLengthExpanded = true
                        }
                        .onChange(of: selectedLengthItem) { newLength in
                            if let id = newLength.id, let length = Double(id) {
                                tempLength = length
                            } else {
                                tempLength = 0.0
                            }
                        }
                        DGDropdownField(
                            title: "How much do you weight?",
                            isExpanded: $isWeightExpanded,
                            chosenItem: $selectedWeightItem
                        )
                        .onTapGesture {
                            isWeightExpanded = true
                        }
                        .onChange(of: selectedWeightItem) { newWeight in
                            if let id = newWeight.id, let weight = Double(id) {
                                tempWeight = weight
                            } else {
                                tempWeight = 0.0
                            }
                        }
                        Divider()
                            .frame(width: UIScreen.screenWidth, height: 1)
                            .background(Color.black)
                    }
                    Spacer()
                    DGButton(text: "Next", backgroundColor: .mkOrange) {
                        viewModel.showIndicator = true
                        if let hkBiologicalSex = viewModel.genderStringToHKBiologicalSex(viewModel.genderOptions[selectedGenderSegmentIndex].text) {
                            ProfileManager.shared.setUserGender(hkBiologicalSex)
                        }
                        ProfileManager.shared.setUserBirthday(validationModel.birthday)
                        if let height = tempLength {
                            ProfileManager.shared.setUserHeight(height / 100)
                        }
                        if let weight = tempWeight {
                            ProfileManager.shared.setUserWeight(weight)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.goToDietPreference = true
                        }
                    }
                }
                .navigationBarBackButtonHidden()
                .navigationBarItems(
                 leading:
                     DGBackButton(),
                 trailing:
                     HStack {
                         DGProgressBar(progressCount: Constant.progressCount, currentProgress: 1, color: .mkPurple, dotColor: .mkPurple.opacity(0.5))
                         Spacer()
                             .frame(width: UIScreen.screenWidth / Constant.progressTrailingScale)
                     }
                )
                .navigationDestination(isPresented: self.$goToDietPreference) {
                    DietPreferenceView()
                }
                .onAppear {
                    viewModel.fetchGenderItems()
                    viewModel.fetchLengthItems()
                    viewModel.fetchWeightItems()
                    if let gender = ProfileManager.shared.user.gender {
                        let genderString = healthKitManager.hkBiologicalSexToGenderString(gender)
                        // Find the index by comparing the string with a property in SegmentTitle
                        selectedGenderItem = viewModel.genderOptions.first { $0.text.lowercased() == genderString.lowercased() } ?? DGDropdownItemModel(id: "", text: "")
                    }
                    if let birthdayString = ProfileManager.shared.user.birthday {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd.MM.yyyy"
                        if let date = formatter.date(from: birthdayString) {
                            birthday = date
                            birthdayText = birthdayString
                        }
                    } else {
                        birthdayText = "Date of Birth"
                    }
                    if let height = ProfileManager.shared.user.height {
                        let heightString = String(format: "%.0f", height * 100) // Convert height to string
                        selectedLengthItem = viewModel.lengthOptions.first { $0.id == heightString } ?? DGDropdownItemModel(id: "", text: "")
                    }
                    if let weight = ProfileManager.shared.user.weight {
                        // Convert weight to an integer string by removing the decimal part
                        let weightString = String(format: "%.0f", weight) // Use "%.0f" to keep only the integer part
                        selectedWeightItem = viewModel.weightOptions.first { $0.id == weightString } ?? DGDropdownItemModel(id: "", text: "")
                    }
                }
                .onDisappear {
                    viewModel.showIndicator = false
                }
                .onChange(of: selectedLengthUnit) { _ in
                    viewModel.loadLengthItems(for: selectedLengthUnit)
                }
                .onChange(of: selectedWeightUnit) { _ in
                    viewModel.loadWeightItems(for: selectedWeightUnit)
                }
            }
                   .heightPickerModifier(
                    lengthOptions: $viewModel.lengthOptions,
                    isExpanded: $isLengthExpanded,
                    selectedItem: $selectedLengthItem,
                    selectedUnit: $selectedLengthUnit
                   )
                   .weightPickerModifier(
                    weightOptions: $viewModel.weightOptions,
                    isExpanded: $isWeightExpanded,
                    selectedItem: $selectedWeightItem,
                    selectedUnit: $selectedWeightUnit
                   )
                   .genderPickerModifier(
                    genderOptions: $viewModel.genderOptions,
                    isExpanded: $isGenderExpanded,
                    selectedItem: $selectedGenderItem
                   )
        }
    }
    
    private func DatePickerView() -> some View {
        HStack {
            Spacer()
            ZStack {
                // Hidden DatePicker
                DatePicker("",
                           selection: $birthday,
                           in: ...Calendar.current.date(byAdding: .year, value: -18, to: Date())!,
                           displayedComponents: .date
                )
                .labelsHidden()
                .clipped()
                .opacity(0.01)
                .allowsHitTesting(true)
                .onChange(of: birthday) { newValue in
                    let formattedDate = newValue.getFormattedDate(format: "dd.MM.yyyy")
                    validationModel.birthday = formattedDate
                    birthdayText = formattedDate
                }
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.mkPurple)
                    .padding(.trailing, 30)
            }
            .frame(width: 50, height: 32)
            .background(Color.clear)
        }
    }
}

struct DetailsAboutMeView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsAboutMeView()
            .environmentObject(UserInputModel()) // Providing the necessary environment object
            .previewLayout(.sizeThatFits) // Adjust the preview layout to fit the content
    }
}
