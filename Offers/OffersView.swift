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
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack {
                DGTitle(
                    title: "Purchase Plans",
                    subtitle: "You can see packages from this list",
                    bottomPadding: -20)
                
                if viewModel.offers.isEmpty {
                    Spacer()
                    Text("There are currently no offerings")
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
            leading: DGBackButton()
        )
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    viewModel.showAlert = false
                    viewModel.errorMessage = ""
                }
            )
        }
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
