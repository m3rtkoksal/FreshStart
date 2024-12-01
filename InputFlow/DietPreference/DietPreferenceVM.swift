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
            title: "Normal",
            description: "No dietary restrictions, includes all food types.",
            icon: "normal",
            infoDescription: "The normal diet includes a wide variety of foods without any specific restrictions. It supports a balanced diet, and is the most common choice for people without dietary limitations.",
            infoCanEat: "You can eat a wide range of foods including meats, vegetables, fruits, grains, dairy products, and fats.",
            infoCantEat: "There are no specific foods that need to be avoided."
        ),
        DietPreferenceItem(
            title: "Vegan",
            description: "Excludes all animal products, including meat, fish, dairy, and eggs.",
            icon: "vegan",
            infoDescription: "A vegan diet excludes all animal-derived foods. It focuses on plant-based foods and aims to avoid all forms of animal exploitation.",
            infoCanEat: "You can eat fruits, vegetables, legumes, grains, nuts, seeds, and plant-based alternatives for dairy and meat.",
            infoCantEat: "You must avoid all animal products including meat, fish, eggs, dairy, honey, and any products made with animal-derived ingredients."
        ),
        DietPreferenceItem(
            title: "Vegetarian",
            description: "Excludes all meat and fish but includes dairy and eggs.",
            icon: "vegetarian",
            infoDescription: "A vegetarian diet excludes meat and fish, but includes other animal-derived products like dairy and eggs. It's often chosen for ethical, health, or environmental reasons.",
            infoCanEat: "You can eat fruits, vegetables, legumes, grains, dairy products, eggs, nuts, and seeds.",
            infoCantEat: "You must avoid meat, poultry, fish, and seafood."
        ),
        DietPreferenceItem(
            title: "Pescatarian",
            description: "Excludes all meat but includes fish, dairy, and eggs.",
            icon: "pescatarian",
            infoDescription: "A pescatarian diet excludes meat but includes fish, making it a fish-based diet that also allows for dairy and eggs.",
            infoCanEat: "You can eat fish, seafood, fruits, vegetables, grains, dairy, eggs, legumes, nuts, and seeds.",
            infoCantEat: "You must avoid red meat (beef, pork) and poultry (chicken, turkey)."
        ),
        DietPreferenceItem(
            title: "Flexitarian",
            description: "Primarily plant-based but occasionally includes meat or fish.",
            icon: "flexitarian",
            infoDescription: "A flexitarian diet is a flexible approach that emphasizes plant-based foods but allows for occasional meat or fish. It’s perfect for those who want the benefits of a vegetarian diet but with flexibility.",
            infoCanEat: "You can eat mostly plant-based foods like vegetables, fruits, grains, legumes, and nuts, but occasionally enjoy meat or fish.",
            infoCantEat: "There are no foods that are strictly prohibited, but limiting processed meats and excessive animal products is advised."
        ),
        DietPreferenceItem(
            title: "No Red Meat",
            description: "Excludes beef, pork, and other red meats, but includes poultry, fish, dairy, and eggs.",
            icon: "no-red-meat",
            infoDescription: "A 'No Red Meat' diet eliminates red meats like beef and pork but allows for other types of animal protein like poultry, fish, and dairy. It’s often chosen for health reasons to reduce the risk of certain diseases.",
            infoCanEat: "You can eat poultry, fish, seafood, dairy products, eggs, vegetables, fruits, and grains.",
            infoCantEat: "You must avoid beef, pork, lamb, and any other red meats."
        ),
        DietPreferenceItem(
            title: "Poultry Only",
            description: "Includes only poultry (chicken, turkey, etc.), along with fish, dairy, and eggs.",
            icon: "poultry-only",
            infoDescription: "A poultry-only diet focuses on eating only poultry (such as chicken and turkey) along with fish, dairy, and eggs. It excludes red meat and may be chosen for various health reasons or dietary preferences.",
            infoCanEat: "You can eat poultry (chicken, turkey), fish, dairy, eggs, vegetables, fruits, and grains.",
            infoCantEat: "You must avoid red meats (beef, pork, lamb) and any other meat sources besides poultry."
        )
    ]
}
