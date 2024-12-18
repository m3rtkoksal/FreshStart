//
//  DGDismissButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FreshStartDismissButton: View {
    @Environment(\.dismiss) private var dismiss
    var color: Color = .black
    
    var body: some View {
        Button {
            withAnimation {
                AuthenticationManager.shared.logIn()
                self.dismiss()
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(color)
                .padding(.leading, 0)
        }
    }
}
