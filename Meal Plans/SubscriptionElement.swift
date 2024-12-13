//
//  SubscriptionElement.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct SubscriptionElement: View {
    @AppStorage("selectedTab") private var selectedTabRaw: String = MainTabView.Tab.offerings.rawValue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle()
                .fill(Color.black)
                .overlay(
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("purchase_plans".localized())
                                .font(.montserrat(.semiBold, size: 18))
                            Text("purchase_description".localized())
                                .font(.montserrat(.medium, size: 10))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .foregroundColor(.white)
                        .padding(.leading, 20)
                        Spacer()
                        ZStack {
                            Image("SubscriptionImage")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .ignoresSafeArea(edges: .trailing)
                        }
                        .frame(maxWidth: 133, maxHeight: 100)
                    }
                )
        }
        .background(Color.clear)
        .frame(height: 100)
        .padding(.top, 20)
        .onTapGesture {
            selectedTabRaw = MainTabView.Tab.offerings.rawValue
        }
    }
}

#Preview {
    SubscriptionElement()
}
