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
    @Published var menuPickerItems:[DGDropdownItemModel] = []
    @Published var goToHealthPermission = false
    @Published var goToLogin = false
    @Published var goToPrivacyPolicy = false
    private let db = Firestore.firestore()
    
    func fetchMenuItems() {
        self.menuPickerItems = [
            DGDropdownItemModel(id: "0", icon: "male", text: "Male", hasArrow: false),
            DGDropdownItemModel(id: "1", icon: "female", text: "Female", hasArrow: false)
        ]
    }
}
