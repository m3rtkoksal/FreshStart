//
//  AdditionalView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct AdditionalView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @ObservedObject private var notificationManager = NotificationManager.shared
    @StateObject private var viewModel = AdditionalVM()
    var body: some View {
        DGView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack(spacing: 30) {
                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack(spacing: 10) {
                            Image("profileMenuChart")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.black)
                            Text("Charts")
                                .font(.montserrat(.semiBold, size: 18))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.leading, 20)
                        HealthDataChartView()
                            .frame(maxWidth: .infinity, minHeight: 257)
                    }
                    .padding(.vertical, 10)
                   
                    ZStack {
                        Color.black
                            .edgesIgnoringSafeArea(.horizontal)
                        VStack {
                            HStack(spacing: 10) {
                                Image("badgeMenuTitle")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                                Text("Badges")
                                    .font(.montserrat(.semiBold, size: 18))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.leading, 20)
                            AdditionalBadgesView()
                                .padding(.vertical, 20)
                        }
                    }
                    .padding(.top, 20)
                    
                    HStack(spacing: 10) {
                        Image("rankingsMenuTitle")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Rankings")
                            .font(.montserrat(.semiBold, size: 18))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(20)
                    AdditionalRankingsView()
                        .edgesIgnoringSafeArea(.horizontal)
                    Spacer()
                        .frame(height: 130)
                }
            }
        }
    }
}

#Preview {
    AdditionalView()
}
