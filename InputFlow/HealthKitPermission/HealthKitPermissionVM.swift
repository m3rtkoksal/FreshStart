//
//  HealthKitPermissionVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

class HealthKitPermissionVM: BaseViewModel {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @StateObject private var healthKitManager = HealthKitManager()
    @Published var goToBMIInputPage = false
    @Published var menuPickerItems:[FSDropdownItemModel] = []
    @Published var goToHealthPermission = false
    @Published var goToLogin = false
    @Published var goToPrivacyPolicy = false
    private let db = Firestore.firestore()
    
    func fetchMenuItems() {
        self.menuPickerItems = [
            FSDropdownItemModel(id: "0", icon: "male", text: "male".localized(), hasArrow: false),
            FSDropdownItemModel(id: "1", icon: "female", text: "female".localized(), hasArrow: false)
        ]
    }
}
