//
//  DGBackButton.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct FreshStartBackButton: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var router: BindingRouter
    var color: Color = .black
    
    var body: some View {
        Button {
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Image("back.button")
                .resizable()
                .renderingMode(.template)
                .frame(width: 10, height: 16)
                .foregroundColor(color)
                .padding(.leading,0)
        }
    }
}
