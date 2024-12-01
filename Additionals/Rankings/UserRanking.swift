//
//  UserRanking.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import Foundation

struct UserRanking {
    let userId: String
    var username: String
    var previousBodyFatPercentage: Double
    var previousLeanBodyMass: Double
    var bodyFatChange: Double
    var muscleGain: Double
    var dailyLoginCount: Int
    var rank: Int
}
