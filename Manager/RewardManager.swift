//
//  RewardManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 4.12.2024.
//


import GoogleMobileAds

class RewardManager: NSObject, ObservableObject, GADFullScreenContentDelegate {
    static let shared = RewardManager()
    @Published var coins = 0
    private var rewardedAd: GADRewardedAd?
    
    func loadAd() async {
        do {
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: "ca-app-pub-9377400955659250~9459391968", request: GADRequest())
            rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded successfully.")
        } catch {
            print("Failed to load rewarded ad with error: \(error.localizedDescription)")
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func ad(
      _ ad: GADFullScreenPresentingAd,
      didFailToPresentFullScreenContentWithError error: Error
    ) {
      print("\(#function) called")
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("\(#function) called")
      // Clear the rewarded ad.
      rewardedAd = nil
    }
    
    func showAd(from rootViewController: UIViewController, onReward: @escaping () -> Void) {
        guard let rewardedAd = rewardedAd else {
            print("Ad wasn't ready.")
            return
        }
        
        rewardedAd.present(fromRootViewController: rootViewController) {
            // Fetch reward details from the ad object
            let reward = rewardedAd.adReward
            print("User earned reward: \(reward.amount.intValue) \(reward.type)")
            DispatchQueue.main.async {
                onReward()
            }
        }
    }
}
