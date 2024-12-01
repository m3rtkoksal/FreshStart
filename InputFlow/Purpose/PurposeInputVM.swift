//
//  PurposeInputVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

class PurposeInputVM: BaseViewModel {
    @Published var goToFrequencyView = false
    @Published var purposeItems: [PurposeItem] = [ PurposeItem(title: "Lose weight", icon: "loseWeight"),
                                                   PurposeItem(title: "Maintain weight", icon: "maintainWeight"),
                                                   PurposeItem(title: "Gain weight", icon: "gainFat"),
                                                   PurposeItem(title: "Gain muscle", icon: "gainMuscle")]
    func getIcon(for purpose: String) -> String? {
        return purposeItems.first(where: { $0.title == purpose })?.icon
    }
}
