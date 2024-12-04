//
//  DGDismissButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FreshStartDismissButton: View {
    var color: Color = .black
    
    var body: some View {
        Button {
            withAnimation {
                AuthenticationManager.shared.logIn()
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(color)
                .padding(.leading, 0)
        }
    }
}
