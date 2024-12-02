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
    
    // Set the indicator visibility based on completion
    func performTaskWithIndicator(completion: @escaping () -> Void) {
        // Show the indicator before starting the task
        setShowIndicator(true)
        
        // Simulate some task that takes time (e.g., network request)
        DispatchQueue.global().async {
            // Simulate a delay
            sleep(2) // Replace with your task, such as a network call
            
            // Once the task is done, hide the indicator and call completion
            DispatchQueue.main.async {
                self.setShowIndicator(false)
                completion() // Notify that the task is finished
            }
        }
    }
    
    private func setShowIndicator(_ show: Bool) {
        DispatchQueue.main.async {
            self.showIndicator = show
        }
    }
}
