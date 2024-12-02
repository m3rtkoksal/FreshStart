//
//  BindingRouter.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

@MainActor
final class BindingRouter: ObservableObject {
    @Binding private var popToRootValue: Bool
    
    init(_ popToRootValue: Binding<Bool> = .constant(false)) {
        self._popToRootValue = popToRootValue
    }
    
    func popToRoot() {
        self.popToRootValue = false
    }
}
