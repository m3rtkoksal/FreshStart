//
//  DetailsAboutMeVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import HealthKit

class DetailsAboutMeVM: BaseViewModel {
    @Published var genderOptions: [DGDropdownItemModel] = []
    @Published var goToBMIInputPage = false
    @StateObject private var healthKitManager = HealthKitManager()
    @Published var dropdownTitle: String = "Select Height"
    @Published var lengthOptions: [DGDropdownItemModel] = []
    @Published var weightOptions: [DGDropdownItemModel] = []
    @Published var selectedLengthUnit: LengthUnit = .cm
    @Published var selectedWeightUnit: WeightUnit = .kg
    
    func fetchGenderItems() {
        self.genderOptions = [
            DGDropdownItemModel(icon: "male", text: "Male"),
            DGDropdownItemModel(icon: "female", text: "Female")
        ]
    }
    
    func loadLengthItems(for unit: LengthUnit) {
        let range: ClosedRange<Int>
        switch unit {
        case .cm:
            range = 130...250
            self.lengthOptions = range.map { DGDropdownItemModel(id: "\($0)", text: "\($0) \(unit.rawValue)") }
        case .ft:
            let step = 0.1
            let range = stride(from: 4.0, to: 8.1, by: step)
            self.lengthOptions = range.map { DGDropdownItemModel(id: String(format: "%.1f", $0), text: String(format: "%.1f \(unit.rawValue)", $0)) }
        }
    }
    
    func fetchLengthItems() {
        loadLengthItems(for: selectedLengthUnit)
    }
    
    func loadWeightItems(for unit: WeightUnit) {
        switch unit {
        case .kg:
            let range = 30...250
            self.weightOptions = range.map { DGDropdownItemModel(id: "\($0)", text: "\($0) \(unit.rawValue)") }
        case .lbs:
            let step = 1.0
            let range = stride(from: 60.0, to: 551.0, by: step)
            self.weightOptions = range.map { DGDropdownItemModel(id: String(format: "%.1f", $0), text: String(format: "%.1f \(unit.rawValue)", $0)) }
        }
    }
    
    func fetchWeightItems() {
        loadWeightItems(for: selectedWeightUnit)
    }
    
    func genderStringToHKBiologicalSex(_ gender: String) -> HKBiologicalSex? {
        switch gender.lowercased() {
        case "male":
            return .male
        case "female":
            return .female
        case "other":
            return .other
        default:
            return nil
        }
    }
}

