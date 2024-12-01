//
//  AdditionalVM.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation
import FirebaseFirestore

class AdditionalVM: BaseViewModel {
    private func fetchAllUsersLoginCounts(completion: @escaping ([UserRankList]) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching user login counts: \(error)")
                completion([])
                return
            }
            
            var userLoginCounts: [UserRankList] = []
            for document in querySnapshot?.documents ?? [] {
                if let username = document.data()["username"] as? String,
                   let dailyLoginCount = document.data()["dailyLoginCount"] as? Double {
                    userLoginCounts.append(UserRankList(id: document.documentID, username: username, rank: nil, value: dailyLoginCount))
                }
            }
            ProfileManager.shared.setAllUsersDailyLoginCountList(userLoginCounts)
            completion(userLoginCounts)
        }
    }
}
