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
    let gridLayout = [GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100)), GridItem(.fixed(100))]
    let spacing: CGFloat = 10
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .black,
               showIndicator: $viewModel.showIndicator) {
            VStack {
                DGTitle(
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
                        LazyVGrid(columns: gridLayout, spacing: spacing) {
                            ForEach(viewModel.badges) { badge in
                                BadgeElementView(badge: badge)
                                    .onTapGesture {
                                        selectedBadge = badge
                                        viewModel.goToBadgeDetailView = true
                                    }
                            }
                        }
                        .padding()
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
                leading: DGBackButton(color: .white)
               )
    }
}

#Preview {
    BadgesView()
}
