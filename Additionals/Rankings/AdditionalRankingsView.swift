//
//  AdditionalRankingsView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct AdditionalRankingsView: View {
    @StateObject private var viewModel = AdditionalRankingsVM()
    @State private var selectedRankType: RankListType = .bodyFat
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            SegmentedControlView(
                selectedIndex: Binding(
                    get: { selectedRankType.rawValue },
                    set: { selectedRankType = RankListType(rawValue: $0) ?? .bodyFat }
                ),
                segmentNames: viewModel.chartSegmentItems
            )
            switch selectedRankType {
            case .bodyFat:
                BodyFatRankingView(rankings: viewModel.bodyFatRankings)
            case .muscleMass:
                MuscleMassRankingView(rankings: viewModel.muscleMassRankings)
            case .dailyLogin:
                DailyLoginRankingView(rankings: viewModel.dailyLoginRankings)
            }
            HStack {
                Spacer()
                Button {
                    viewModel.showAllRanking = true
                } label: {
                    HStack {
                        Text("show_all_rankings".localized())
                        Image(systemName: "chevron.right")
                    }
                    .font(.montserrat(.bold, size: 12))
                    .foregroundColor(Color.borderGray)
                    .padding(.top)
                }
            }
            .padding(.trailing, 33)
        }
        .background(Color.white)
        .onAppear {
            viewModel.bodyFatRankings = viewModel.calculateWeeklyChanges(
                selectedRankType: .bodyFat,
                isTopFive: true
            )
            for i in 0..<viewModel.bodyFatRankings.count {
                viewModel.bodyFatRankings[i].rank = i + 1
            }
            viewModel.muscleMassRankings = viewModel.calculateWeeklyChanges(
                selectedRankType: .muscleMass,
                isTopFive: true
            )
            for i in 0..<viewModel.muscleMassRankings.count {
                viewModel.muscleMassRankings[i].rank = i + 1
            }
            viewModel.dailyLoginRankings = viewModel.calculateWeeklyChanges(
                selectedRankType: .dailyLogin,
                isTopFive: true
            )
            for i in 0..<viewModel.dailyLoginRankings.count {
                viewModel.dailyLoginRankings[i].rank = i + 1
            }
        }
        
        .navigationDestination(isPresented: $viewModel.showAllRanking) {
            AllRankingView()
        }
        .edgesIgnoringSafeArea(.horizontal)
    }
}

struct BodyFatRankingView: View {
    var rankings: [UserRanking]
    
    var body: some View {
        VStack {
            if rankings.isEmpty {
                FreshStartLoadingView()
            } else {
                HStack {
                    Text("ranking".localized())
                    Text("user".localized())
                        .padding(.leading, 40)
                    Spacer()
                    Text("fat_lose_percentage".localized())
                        .frame(alignment: .trailing)
                }
                .font(.montserrat(.medium, size: 10))
                .padding(.trailing, 50)
                .padding(.leading, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                Divider()
                    .frame(height: 0.5)
                    .background(Color.gray)
                let sortedRankings = rankings.sorted { ($0.bodyFatChange) > ($1.bodyFatChange) }
                ForEach(sortedRankings, id: \.userId) { ranking in
                    let medalIcon = ranking.rank <= 5 ? "\(ranking.rank).medal" : "rest.medal"
                    RankElementView(userId: ranking.userId,
                                    username: ranking.username,
                                    text: ranking.bodyFatChange,
                                    selectedRankType: .bodyFat,
                                    rankIcon: "\(ranking.rank).circle",
                                    medalIcon: medalIcon)
                }
                .padding(.top)
            }
        }
    }
}

// MuscleMassRankingView to display rankings based on muscle mass
struct MuscleMassRankingView: View {
    var rankings: [UserRanking]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            if rankings.isEmpty {
                FreshStartLoadingView()
            } else {
                HStack {
                    Text("ranking".localized())
                    Text("user".localized())
                        .padding(.leading, 40)
                    Spacer()
                    Text("muscle_gain".localized())
                        .frame(alignment: .trailing)
                }
                .font(.montserrat(.medium, size: 10))
                .padding(.trailing, 60)
                .padding(.leading, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                Divider()
                    .frame(height: 0.5)
                    .background(Color.gray)
                let sortedRankings = rankings.sorted { ($0.muscleGain) > ($1.muscleGain) }
                ForEach(sortedRankings, id: \.userId) { ranking in
                    let medalIcon = ranking.rank <= 5 ? "\(ranking.rank).medal" : "rest.medal"
                    RankElementView(userId: ranking.userId,
                                    username: ranking.username,
                                    text: ranking.muscleGain,
                                    selectedRankType: .muscleMass,
                                    rankIcon: "\(ranking.rank).circle",
                                    medalIcon: medalIcon)
                }
                .padding(.top)
            }
        }
    }
}
struct DailyLoginRankingView: View {
    var rankings: [UserRanking]
    var body: some View {
        VStack(alignment: .leading) {
            if rankings.isEmpty {
                FreshStartLoadingView()
            } else {
                HStack {
                    Text("ranking".localized())
                    Text("user".localized())
                        .padding(.leading, 40)
                    Spacer()
                    Text("score".localized())
                        .frame(alignment: .trailing)
                }
                .padding(.trailing, 50)
                .padding(.leading, 20)
                .padding(.top, 10)
                .frame(maxWidth: .infinity)
                .font(.montserrat(.medium, size: 10))
                Divider()
                    .frame(height: 0.5)
                    .background(Color.gray)
                let sortedRankings = rankings.sorted { ($0.dailyLoginCount) > ($1.dailyLoginCount) }
                ForEach(sortedRankings, id: \.userId) { ranking in
                    let medalIcon = ranking.rank <= 5 ? "\(ranking.rank).medal" : "rest.medal"
                    RankElementView(userId: ranking.userId,
                                    username: ranking.username,
                                    text: Double(ranking.dailyLoginCount),
                                    selectedRankType: .dailyLogin,
                                    rankIcon: "\(ranking.rank).circle",
                                    medalIcon: medalIcon)
                }
                .padding(.top)
            }
        }
    }
}
