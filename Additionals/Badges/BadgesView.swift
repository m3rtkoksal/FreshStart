//
//  BadgesView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct BadgesView: View {
    @StateObject var viewModel = BadgesVM()
    @State var selectedBadge = BadgeModel()
    let gridLayout = [GridItem(.adaptive(minimum: 90, maximum: 100), spacing: 10)]
    let horizontalPadding: CGFloat = UIScreen.main.bounds.width > 375 ? 16 : 8
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .black,
               showIndicator: $viewModel.showIndicator) {
            VStack {
                FSTitle(
                    title: "Your Achievements",
                    subtitle: "Earn badges by completing challenges and reaching your goals.",
                    bottomPadding: -5,
                    color: .white)
                if viewModel.badges.isEmpty {
                    Text("Earn badges by completing challenges!")
                        .font(.montserrat(.medium, size: 16))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                } else {
                    ScrollView(.vertical) {
                        LazyVGrid(columns: gridLayout, spacing: 10) {
                            ForEach(viewModel.badges) { badge in
                                BadgeElementView(badge: badge)
                                    .onTapGesture {
                                        selectedBadge = badge
                                        viewModel.goToBadgeDetailView = true
                                    }
                            }
                        }
                        .padding(.horizontal, horizontalPadding)
                    }
                    Spacer()
                }
            }
            .sheet(isPresented: $viewModel.goToBadgeDetailView) {
                BadgeDetailView(badge: selectedBadge)
                    .presentationDetents([.fraction(0.3)])
            }
        }
               .navigationBarBackButtonHidden()
               .navigationBarItems(
                leading: FreshStartBackButton(color: .white)
               )
    }
}

#Preview {
    BadgesView()
}
