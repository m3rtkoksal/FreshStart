//
//  AllRankingView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct AllRankingView: View {
    @StateObject private var viewModel = AdditionalRankingsVM()
    @State private var selectedRankType: RankListType = .bodyFat
    
    var body: some View {
        FreshStartBaseView(currentViewModel: viewModel,
               background: .solidWhite,
               showIndicator: $viewModel.showIndicator) {
            VStack {
                SegmentedControlView(
                    selectedIndex: Binding(
                        get: { selectedRankType.rawValue },
                        set: { selectedRankType = RankListType(rawValue: $0) ?? .bodyFat }
                    ),
                    segmentNames: viewModel.chartSegmentItems)
                DGTitle(
                    title: "All Rankings",
                    subtitle: "",
                    bottomPadding: -5)
                ScrollView {
                    PrizeExplanationElement()
                        .padding(.vertical)
                    switch selectedRankType {
                    case .bodyFat:
                        BodyFatRankingView(rankings: viewModel.bodyFatRankings)
                    case .muscleMass:
                        MuscleMassRankingView(rankings: viewModel.muscleMassRankings)
                    case .dailyLogin:
                        DailyLoginRankingView(rankings: viewModel.dailyLoginRankings)
                    }
                    Spacer()
                }
            }
            .onAppear {
                viewModel.bodyFatRankings = viewModel.calculateWeeklyChanges(
                    selectedRankType: .bodyFat,
                    isTopFive: false
                )
                for i in 0..<viewModel.bodyFatRankings.count {
                    viewModel.bodyFatRankings[i].rank = i + 1
                }
                viewModel.muscleMassRankings = viewModel.calculateWeeklyChanges(
                    selectedRankType: .muscleMass,
                    isTopFive: false
                )
                for i in 0..<viewModel.muscleMassRankings.count {
                    viewModel.muscleMassRankings[i].rank = i + 1
                }
                viewModel.dailyLoginRankings = viewModel.calculateWeeklyChanges(
                    selectedRankType: .dailyLogin,
                    isTopFive: false
                )
                for i in 0..<viewModel.dailyLoginRankings.count {
                    viewModel.dailyLoginRankings[i].rank = i + 1
                }
            }
        }
               .navigationBarBackButtonHidden()
               .navigationBarItems(
                leading: DGBackButton()
               )
    }
}

#Preview {
    AllRankingView()
}
