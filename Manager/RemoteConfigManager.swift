//
//  RemoteConfigManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import FirebaseRemoteConfig

class RemoteConfigManager {
    static let shared = RemoteConfigManager()
    private var remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            "openAIKey": "" as NSObject,
            "revenueCatKey": "" as NSObject
        ])
    }

    func fetchAPIKeys(completion: @escaping (String?) -> Void) {
        remoteConfig.fetchAndActivate { status, error in
            if status == .successFetchedFromRemote || status == .successUsingPreFetchedData {
                let revenueKey = self.remoteConfig["revenueCatKey"].stringValue
                let openAIKey = self.remoteConfig["openAIKey"].stringValue
                completion(openAIKey)
            } else {
                completion(nil)
            }
        }
    }
}
