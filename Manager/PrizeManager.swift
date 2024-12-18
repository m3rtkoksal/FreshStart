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
    private var timer: DispatchSourceTimer?
    private var isProcessing = false
    
    init() {
        startPrizeCheckTimer()
    }
    
    private func startPrizeCheckTimer() {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: .seconds(60))
        timer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.checkIfItIsPrizeTime()
            }
        }
        timer.resume()
        self.timer = timer
    }
    
    @objc func checkIfItIsPrizeTime() {
        guard !isProcessing else { return }
        isProcessing = true
        
        let now = Date()
        if isSundayMidnight(now) {
            awardTop5Members()
            resetRankings()
        }
        
        isProcessing = false
    }
    
    private func isSundayMidnight(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        return components.weekday == 1 && components.hour == 0 && components.minute ?? 0 < 2
    }
    
    private func awardTop5Members() {
        let top5FatMembers = userRankingViewModel.calculateWeeklyChanges(
            selectedRankType: .bodyFat, isTopFive: true)
        let top5MuscleMembers = userRankingViewModel.calculateWeeklyChanges(
            selectedRankType: .muscleMass, isTopFive: true)
        let top5LoginMembers = userRankingViewModel.calculateWeeklyChanges(
            selectedRankType: .dailyLogin, isTopFive: true)
        
        for (index, member) in top5FatMembers.enumerated() where member.bodyFatChange > 0 {
            let days = getRewardForRank(rank: index + 1)
            updateSubscriptionEndDateInFirestore(userId: member.userId, days: days)
        }
        for (index, member) in top5MuscleMembers.enumerated() where member.muscleGain > 0 {
            let days = getRewardForRank(rank: index + 1)
            updateSubscriptionEndDateInFirestore(userId: member.userId, days: days)
        }
        for (index, member) in top5LoginMembers.enumerated() where member.dailyLoginCount > 0 {
            let days = getRewardForRank(rank: index + 1)
            updateSubscriptionEndDateInFirestore(userId: member.userId, days: days)
        }
    }
    
    private func getRewardForRank(rank: Int) -> Int {
        switch rank {
        case 1: return 7
        case 2: return 5
        case 3: return 3
        case 4: return 2
        case 5: return 1
        default: return 0
        }
    }
    
    private func updateSubscriptionEndDateInFirestore(userId: String, days: Int) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            guard let document = document, document.exists else {
                print("Error fetching user \(userId): \(error?.localizedDescription ?? "Document does not exist")")
                return
            }
            
            let data = document.data()
            let additionalTime = TimeInterval(days * 86400)
            let newEndDate: Date
            if let currentEndDateTimestamp = data?["subscriptionEndDate"] as? Timestamp {
                newEndDate = currentEndDateTimestamp.dateValue().addingTimeInterval(additionalTime)
            } else {
                newEndDate = Date().addingTimeInterval(additionalTime)
            }
            
            db.collection("users").document(userId).updateData([
                "subscriptionEndDate": Timestamp(date: newEndDate),
                "isPremiumUser": true
            ]) { error in
                if let error = error {
                    print("Error updating subscription end date for user \(userId): \(error.localizedDescription)")
                } else {
                    print("Successfully updated subscription end date for user \(userId).")
                }
            }
        }
    }
    
    private func resetRankings() {
        self.resetWeeklyRankings()
        print("Rankings have been reset for the week.")
    }
    
    private func resetWeeklyRankings() {
        // Assuming rankings data is stored in a Firestore collection called "rankings"
        let db = Firestore.firestore()
        let rankingsCollection = db.collection("rankings")
        
        // Fetch all rankings documents
        rankingsCollection.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching rankings: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No rankings found to reset.")
                return
            }
            
            // Iterate through each document to reset weekly values
            for document in documents {
                // Reset ranking-related fields to 0 or default
                rankingsCollection.document(document.documentID).updateData([
                    "weeklyPoints": 0,
                    "weeklyFatChange": 0,
                    "weeklyMuscleGain": 0,
                    "weeklyLoginCount": 0
                ]) { error in
                    if let error = error {
                        print("Error resetting ranking for document \(document.documentID): \(error.localizedDescription)")
                    } else {
                        print("Successfully reset ranking for document \(document.documentID).")
                    }
                }
            }
        }
    }
    
    deinit {
        timer?.cancel()
    }
}
