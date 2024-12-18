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
            VStack(alignment: .leading) {
                FSTitle(
                    title: "disclaimer_and_data_privacy_title".localized(),
                    subtitle: "",
                    bottomPadding: 0)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("disclaimer_and_data_privacy_title".localized())
                            .font(.montserrat(.bold, size: 18))
                            .padding(.top)
                        Text("disclaimer_and_data_privacy_text".localized())
                        Text("our_promise_to_you_title".localized())
                            .font(.montserrat(.bold, size: 18)) // Bold Title
                        Text("our_promise_to_you_text".localized())
                        Text("sources_and_information_accuracy_title".localized())
                            .font(.montserrat(.bold, size: 18)) // Bold Title
                        Text("sources_and_information_accuracy_text".localized())
                        Text("how_we_use_your_health_data_title".localized())
                            .font(.montserrat(.bold, size: 18)) // Bold Title
                        Text("how_we_use_your_health_data_text".localized())
                        Text("our_commitment_to_privacy_and_security_title".localized())
                            .font(.montserrat(.bold, size: 18)) // Bold Title
                        Text("our_commitment_to_privacy_and_security_text".localized())
                        Text("questions_title".localized())
                            .font(.montserrat(.bold, size: 18)) // Bold Title
                        Text("questions_text".localized())
                    }
                    .padding(.horizontal)
                    .font(.montserrat(.regular, size: 16)) // Body text style
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarBackButtonHidden()
        .navigationBarItems(
            leading: FreshStartBackButton()
        )
    }
}

#Preview {
    ResourcesView()
}
