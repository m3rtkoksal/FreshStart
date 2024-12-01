//
//  AdditionalBadgesView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct AdditionalBadgesView: View {
    @StateObject var viewModel = BadgesVM()
    let gridLayout = [GridItem(.fixed(110)), GridItem(.fixed(110))]
    
    var body: some View {
        VStack {
            LazyHGrid(rows: gridLayout, spacing: 20) {
                ForEach(viewModel.badges.prefix(8)) { badge in
                    BadgeElementView(badge: badge)
                }
            }
            HStack {
                Spacer()
                Button {
                    viewModel.goToBadgeView = true
                } label: {
                    HStack {
                        Text("Show All Badges")
                        Image(systemName: "chevron.right")
                    }
                    .font(.montserrat(.bold, size: 12))
                    .foregroundColor(Color.borderGray)
                    .padding(.top)
                }
            }
            .padding(.trailing, 33)
        }
        .background(Color.black)
        .navigationDestination(isPresented: $viewModel.goToBadgeView) {
            BadgesView()
        }
    }
}
