//
//  OffersView.swift
//  FreshStart
//
//  Created by Mert Köksal on 2.12.2024.
//

import SwiftUI

struct OffersView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = OffersVM()
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.diary.rawValue
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack {
                FSTitle(
                    title: "purchase_plans".localized(),
                    subtitle: "purchase_plans_subtitle".localized(),
                    bottomPadding: -20)
                
                if viewModel.offers.isEmpty {
                    Spacer()
                    Text("no_offerings".localized())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 30) {
                            ForEach(viewModel.offers, id: \.self) { product in
                                OfferElement(
                                    product: product,
                                    image: getImageFromProduct(for: product.productIdentifier),
                                    purchaseAction: { selectedProduct in
                                        viewModel.purchaseProduct(product: selectedProduct)
                                    })
                                .padding(.top, 30)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        Spacer()
                            .frame(height: 150)
                    }
                    .padding(.top, 30)
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarItems(
            leading: FreshStartBackButton()
        )
        .fsAlertModifier(
            isPresented: $viewModel.showAlert,
            title: "error_title".localized(),
            message: "error_message".localized(),
            confirmButtonText: "ok_button".localized(),
            confirmAction: {
                withAnimation {
                    viewModel.showAlert = false
                    viewModel.errorMessage = ""
                }
            }
        )
        .onAppear {
            viewModel.fetchProducts()
        }
        .onReceive(viewModel.$purchaseCompleted) { purchaseCompleted in
            if purchaseCompleted {
                selectedTabRaw = MainTabView.Tab.diary.rawValue
            }
        }
    }
    
    private func getImageFromProduct(for productId: String) -> String {
        switch productId {
        case "week_one":
            return "offer1"
        case "week_two":
            return "offer2"
        case "month_one":
            return "offer3"
        case "month_six":
            return "offer5"
        case "year_one":
            return "offer6"
        default:
            return ""
        }
    }
}
