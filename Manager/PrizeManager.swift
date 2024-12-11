//
//  PrizeManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class PrizeManager: ObservableObject {
    var userRankingViewModel = AdditionalRankingsVM()
    var timer: Timer?

    init() {
        startPrizeCheckTimer()
    }
    
    private func startPrizeCheckTimer() {
        // Timer that fires every minute to check if it's time to award the prize
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(checkIfItIsPrizeTime), userInfo: nil, repeats: true)
    }

    @objc private func checkIfItIsPrizeTime() {
        let now = Date()
        if isSundayMidnight(now) {
            awardTop5Members()
            resetRankings()
        }
    }

    // Check if current date and time is Sunday at 00:00
    private func isSundayMidnight(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        return components.weekday == 1 && components.hour == 0 && components.minute == 0
    }
    
    private func awardTop5Members() {
        let top5FatMembers = self.userRankingViewModel.calculateWeeklyChanges(
            selectedRankType: .bodyFat, // Fetch top 5 body fat rankings
            isTopFive: true
        )
        let top5MuscleMembers = self.userRankingViewModel.calculateWeeklyChanges(
            selectedRankType: .muscleMass, // Fetch top 5 muscle mass rankings
            isTopFive: true
        )
        let top5LoginMembers = self.userRankingViewModel.calculateWeeklyChanges(
            selectedRankType: .dailyLogin, // Fetch top 5 daily login rankings
            isTopFive: true
        )

        // Award the top 5 members in each category
        for (index, member) in top5FatMembers.enumerated() {
            if member.bodyFatChange > 0 {
                let days = self.getRewardForRank(rank: index + 1)
                self.updateSubscriptionEndDateInFirestore(userId: member.userId, days : days)
            }
        }

        for (index, member) in top5MuscleMembers.enumerated() {
            if member.muscleGain > 0 {
                let days = self.getRewardForRank(rank: index + 1)
                self.updateSubscriptionEndDateInFirestore(userId: member.userId, days : days)
            }
        }

        for (index, member) in top5LoginMembers.enumerated() {
            if member.dailyLoginCount > 0 {
                let days = self.getRewardForRank(rank: index + 1)
                self.updateSubscriptionEndDateInFirestore(userId: member.userId, days : days)
            }
        }
    }


    // Get reward based on rank
    private func getRewardForRank(rank: Int) -> (Int) {
        switch rank {
        case 1:
            return 7
        case 2:
            return 5
        case 3:
            return 3
        case 4:
            return 2
        case 5:
            return 1
        default:
            return 0
        }
    }

    private func updateSubscriptionEndDateInFirestore(userId: String, days: Int) {
        // Fetch the current user’s data from Firestore
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                
                // Get the current subscription end date, or set to the current date if not available
                let currentEndDateTimestamp = data?["subscriptionEndDate"] as? Timestamp
                var currentEndDate = currentEndDateTimestamp?.dateValue() ?? Date()
                // Update the subscription end date by adding the reward days
                currentEndDate.addTimeInterval(TimeInterval(days * 86400)) // 86400 seconds in a day
                
                // Save the updated subscription end date back to Firestore
                db.collection("users").document(userId).updateData([
                    "subscriptionEndDate": Timestamp(date: currentEndDate),
                    "isPremiumUser": true
                ]) { error in
                    if let error = error {
                        print("Error updating subscription end date: \(error.localizedDescription)")
                    } else {
                        print("Successfully updated subscription end date.")
                    }
                }
            }
        }
    }
    
    private func resetRankings() {
        // Reset the rankings here (you can adjust based on your needs)
        print("Rankings have been reset for the week.")
        // Example: self.userRankingViewModel.resetWeeklyRankings() (adjust based on your implementation)
    }
    
    deinit {
        timer?.invalidate()
    }
}
