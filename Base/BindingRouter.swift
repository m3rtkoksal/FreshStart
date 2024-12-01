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

@MainActor
final class BindingDataRouter<Value>: ObservableObject {
    @Binding private var popToRootValue: Bool
    private var data: Binding<Value>?
    
    init(_ popToRootValue: Binding<Bool> = .constant(false), data: Binding<Value>? = nil) {
        self._popToRootValue = popToRootValue
        self.data = data
    }
    
    func popToRoot() {
        self.popToRootValue = false
    }
    
    func getData() -> Value? {
        self.data?.wrappedValue
    }
    
    func getUnderlyingBinding() -> Binding<Value>? {
        self.data
    }
    
    func setData(data: Value) {
        self.data?.wrappedValue = data
    }
}
