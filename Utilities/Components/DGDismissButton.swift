//
//  DGDismissButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct DGDismissButton: View {
    @Environment(\.dismiss) private var dismiss
    var presentationMode: Binding<PresentationMode>
    var toRoot = false
    var color: Color = .black
    
    var body: some View {
        Button {
            NavigationUtil.popToRootView()
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(color)
                .padding(.leading, 0)
        }
    }
}
