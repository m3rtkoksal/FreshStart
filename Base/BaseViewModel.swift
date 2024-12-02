//
//  BaseViewModel.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import SwiftUI

class BaseViewModel: NSObject, ObservableObject {
    @Published var showIndicator = false
    @Published var alertMessage: String = ""
}
