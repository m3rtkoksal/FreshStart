//
//  ResourcesView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct ResourcesView: View {
    @StateObject private var viewModel = ResourcesVM()
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
                 showIndicator: $viewModel.showIndicator) {
            VStack {
                FSTitle(
                    title: "Disclaimer & Data Privacy",
                    subtitle: "",
                    bottomPadding: 0)
                ScrollView {
                    Text(viewModel.text)
                        .padding(.horizontal)
                        .font(.montserrat(.regular, size: 16))
                }
            }
        }
                 .navigationBarTitle("")
                 .navigationBarBackButtonHidden()
                 .navigationBarItems(
                    leading:
                        FreshStartBackButton()
                 )
                 .onAppear {
                     viewModel.fetchResources()
                 }
    }
}

#Preview {
    ResourcesView()
}
