//
//  PurposeInputVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

class PurposeInputVM: BaseViewModel {
    @Published var goToFrequencyView = false
    @Published var purposeItems: [PurposeItem] = [
        PurposeItem(title: "lose_weight".localized(), icon: "loseWeight"),
        PurposeItem(title: "maintain_weight".localized(), icon: "maintainWeight"),
        PurposeItem(title: "gain_weight".localized(), icon: "gainFat"),
        PurposeItem(title: "gain_muscle".localized(), icon: "gainMuscle")
    ]
    
    func getIcon(for purpose: String) -> String? {
        return purposeItems.first(where: { $0.title == purpose.localized() })?.icon
    }
}
