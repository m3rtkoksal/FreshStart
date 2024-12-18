//
//  AdditionalRankingsVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

enum RankListType: Int {
    case bodyFat
    case muscleMass
    case dailyLogin
}

class AdditionalRankingsVM: BaseViewModel {
    @Published var isTopFive: Bool = false
    @Published var showAllRanking: Bool = false
    @Published var chartSegmentItems: [SegmentTitle] = [
        SegmentTitle(title: "body_fat_percentage".localized()),
        SegmentTitle(title: "muscle_mass".localized()),
        SegmentTitle(title: "daily_login".localized())
    ]
    @Published var bodyFatRankings: [UserRanking] = []
    @Published var muscleMassRankings: [UserRanking] = []
    @Published var dailyLoginRankings: [UserRanking] = []
    
    func calculateWeeklyChanges(
        selectedRankType: RankListType,
        isTopFive: Bool
    ) -> [UserRanking] {
        var userRankings = [String: UserRanking]()
        
        // Iterate over userDailyLoginCountList, userBodyFatPercentageList, and userLeanBodyMassList
        for dailyLogin in ProfileManager.shared.user.userDailyLoginCountList {
            guard let userId = dailyLogin.id else { continue }
            let username = dailyLogin.username?.isEmpty == false ? dailyLogin.username ?? userId : userId
            // If the user is already in the rankings, update their data
            if var existingRanking = userRankings[userId] {
                // Update daily login count
                existingRanking.dailyLoginCount = Int(dailyLogin.value ?? 0)
                userRankings[userId] = existingRanking
            } else {
                // If this is the first time encountering the user, create a new UserRanking entry
                let newRanking = UserRanking(
                    userId: userId,
                    username: username,
                    previousBodyFatPercentage: 0.0,
                    previousLeanBodyMass: 0.0,
                    bodyFatChange: 0.0,
                    muscleGain: 0.0,
                    dailyLoginCount: Int(dailyLogin.value ?? 0),
                    rank: 0
                )
                userRankings[userId] = newRanking
            }
        }
        
        // Now process the body fat and lean mass changes
        for fatPercentage in ProfileManager.shared.user.userBodyFatPercentageList {
            guard let userId = fatPercentage.id else { continue }
            let username = fatPercentage.username?.isEmpty == false ? fatPercentage.username ?? userId : userId
            // Update userRanking based on body fat percentage
            if var existingRanking = userRankings[userId] {
                let bodyFatChange = (fatPercentage.value ?? 0.0) - existingRanking.previousBodyFatPercentage
                existingRanking.bodyFatChange += bodyFatChange
                existingRanking.previousBodyFatPercentage = fatPercentage.value ?? 0.0
                userRankings[userId] = existingRanking
            } else {
                // If the user doesn't exist in rankings, create a new ranking entry
                let newRanking = UserRanking(
                    userId: userId,
                    username: username,
                    previousBodyFatPercentage: fatPercentage.value ?? 0.0,
                    previousLeanBodyMass: 0.0,
                    bodyFatChange: 0.0,
                    muscleGain: 0.0,
                    dailyLoginCount: 0,
                    rank: 0
                )
                userRankings[userId] = newRanking
            }
        }

        // Process the lean body mass changes similarly
        for leanMass in ProfileManager.shared.user.userLeanBodyMassList {
            guard let userId = leanMass.id else { continue }
            let username = leanMass.username?.isEmpty == false ? leanMass.username ?? userId : userId
            // Update userRanking based on lean body mass
            if var existingRanking = userRankings[userId] {
                let muscleGain = (leanMass.value ?? 0.0) - existingRanking.previousLeanBodyMass
                existingRanking.muscleGain += muscleGain
                existingRanking.previousLeanBodyMass = leanMass.value ?? 0.0
                userRankings[userId] = existingRanking
            } else {
                // If the user doesn't exist in rankings, create a new ranking entry
                let newRanking = UserRanking(
                    userId: userId,
                    username: username,
                    previousBodyFatPercentage: 0.0,
                    previousLeanBodyMass: leanMass.value ?? 0.0,
                    bodyFatChange: 0.0,
                    muscleGain: 0.0,
                    dailyLoginCount: 0,
                    rank: 0
                )
                userRankings[userId] = newRanking
            }
        }
        var rankingsArray = Array(userRankings.values)
        switch selectedRankType {
        case .bodyFat:
            rankingsArray.sort { $0.bodyFatChange > $1.bodyFatChange } // Sort by body fat change (descending)
        case .muscleMass:
            rankingsArray.sort { $0.muscleGain > $1.muscleGain } // Sort by muscle gain (descending)
        case .dailyLogin:
            rankingsArray.sort { ($0.dailyLoginCount) > ($1.dailyLoginCount) } // Sort by daily login count (descending)
        }
        var currentRank = 1
        for i in 0..<rankingsArray.count {
            if i > 0 {
                let prevRanking = rankingsArray[i - 1]
                let currentRanking = rankingsArray[i]
                if compareRankingValues(prevRanking, currentRanking, selectedRankType: selectedRankType) {
                    currentRank = prevRanking.rank
                } else {
                    currentRank = i + 1
                }
            }
            rankingsArray[i].rank = currentRank
        }
        return isTopFive ? Array(rankingsArray.prefix(5)) : rankingsArray
    }
    func compareRankingValues(_ prevRanking: UserRanking, _ currentRanking: UserRanking, selectedRankType: RankListType) -> Bool {
        switch selectedRankType {
        case .bodyFat:
            return prevRanking.bodyFatChange == currentRanking.bodyFatChange
        case .muscleMass:
            return prevRanking.muscleGain == currentRanking.muscleGain
        case .dailyLogin:
            return prevRanking.dailyLoginCount == currentRanking.dailyLoginCount
        }
    }
}
