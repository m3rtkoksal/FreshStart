//
//  ProfileVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseFirestore

class ProfileVM: BaseViewModel {
    @Published var goToChangeFirstName: Bool = false
    @Published var goToChangeSurname: Bool = false
    @Published var goToResources: Bool = false
    @Published var goToContactSupport: Bool = false
    @Published var goToLeaveReview: Bool = false
    @Published var goToNotifications: Bool = false
    @Published var goToChangeUsername: Bool = false
    @Published var goToChangeLanguage: Bool = false
}
