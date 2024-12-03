//
//  FreshStartAlertModifier.swift
//  FreshStart
//
//  Created by Mert Köksal on 3.12.2024.
//

import SwiftUI

struct FreshStartAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmButtonText: String
    let cancelButtonText: String?
    let confirmAction: () -> Void
    let cancelAction: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
            if isPresented {
                FreshStartAlertView(
                    title: title,
                    message: message,
                    confirmButtonText: confirmButtonText,
                    cancelButtonText: cancelButtonText,
                    confirmAction: {
                        withAnimation {
                            isPresented = false
                        }
                        confirmAction()
                    },
                    cancelAction: {
                        withAnimation {
                            isPresented = false
                        }
                        cancelAction?()
                    }
                )
            }
        }
        .animation(.easeInOut, value: isPresented)
    }
}
// Extension for easier use
extension View {
    func fsAlertModifier(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmButtonText: String,
        cancelButtonText: String? = nil,
        confirmAction: @escaping () -> Void,
        cancelAction: (() -> Void)? = nil
    ) -> some View {
        self.modifier(FreshStartAlertModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmButtonText: confirmButtonText,
            cancelButtonText: cancelButtonText,
            confirmAction: confirmAction,
            cancelAction: cancelAction
        ))
    }
}
