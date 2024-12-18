//
//  DietPreferenceVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 18.11.2024.
//


import Foundation

class DietPreferenceVM: BaseViewModel {
    @Published var goToHowActiveView = false
    @Published var dietPreferenceItems: [DietPreferenceItem] = [
        DietPreferenceItem(
            title: "normal_title".localized(),
            description: "normal_description".localized(),
            icon: "normal",
            infoDescription: "normal_info_description".localized(),
            infoCanEat: "normal_info_can_eat".localized(),
            infoCantEat: "normal_info_cant_eat".localized()
        ),
        DietPreferenceItem(
            title: "vegan_title".localized(),
            description: "vegan_description".localized(),
            icon: "vegan",
            infoDescription: "vegan_info_description".localized(),
            infoCanEat: "vegan_info_can_eat".localized(),
            infoCantEat: "vegan_info_cant_eat".localized()
        ),
        DietPreferenceItem(
            title: "vegetarian_title".localized(),
            description: "vegetarian_description".localized(),
            icon: "vegetarian",
            infoDescription: "vegetarian_info_description".localized(),
            infoCanEat: "vegetarian_info_can_eat".localized(),
            infoCantEat: "vegetarian_info_cant_eat".localized()
        ),
        DietPreferenceItem(
            title: "pescatarian_title".localized(),
            description: "pescatarian_description".localized(),
            icon: "pescatarian",
            infoDescription: "pescatarian_info_description".localized(),
            infoCanEat: "pescatarian_info_can_eat".localized(),
            infoCantEat: "pescatarian_info_cant_eat".localized()
        ),
        DietPreferenceItem(
            title: "flexitarian_title".localized(),
            description: "flexitarian_description".localized(),
            icon: "flexitarian",
            infoDescription: "flexitarian_info_description".localized(),
            infoCanEat: "flexitarian_info_can_eat".localized(),
            infoCantEat: "flexitarian_info_cant_eat".localized()
        ),
        DietPreferenceItem(
            title: "no_red_meat_title".localized(),
            description: "no_red_meat_description".localized(),
            icon: "no-red-meat",
            infoDescription: "no_red_meat_info_description".localized(),
            infoCanEat: "no_red_meat_info_can_eat".localized(),
            infoCantEat: "no_red_meat_info_cant_eat".localized()
        ),
        DietPreferenceItem(
            title: "poultry_only_title".localized(),
            description: "poultry_only_description".localized(),
            icon: "poultry-only",
            infoDescription: "poultry_only_info_description".localized(),
            infoCanEat: "poultry_only_info_can_eat".localized(),
            infoCantEat: "poultry_only_info_cant_eat".localized()
        )
    ]
}
