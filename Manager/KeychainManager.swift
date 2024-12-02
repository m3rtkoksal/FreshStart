//
//  KeychainManager.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import Foundation
import KeychainSwift

public enum KeychainKey: Int, CaseIterable {
    case openAIKey
    case revenueCatToken  // Add this line

    var key: String {
        switch self {
        case .openAIKey: return "openAIKey"
        case .revenueCatToken: return "revenueCatToken"
        }
    }
}

class KeychainManager{
    
    static let shared = KeychainManager()
    
    let keychain = KeychainSwift()
    
    // MARK: SET TO KEYCHAIN
    public func saveToKeychain(data: String, forKey: KeychainKey){
        if keychain.set(data, forKey: forKey.key, withAccess: .accessibleWhenUnlocked){
            print("Saved To Keychain")
        }else{
            print("Failed to Save Keychain")
        }
    }
    
    func saveDataToKeychain(data: Data, forKey key: KeychainKey) {
        if keychain.set(data, forKey: key.key, withAccess: .accessibleWhenUnlocked) {
            print("Key saved to Keychain successfully")
        } else {
            print("Failed to save key to Keychain")
        }
    }
    
    func getDataFromKeychain(forKey key: KeychainKey) -> Data? {
        return keychain.getData(key.key)
    }
    
    // MARK: GET STRING FROM KEYCHAIN
    public func getStringFromKeychain(forKey: KeychainKey) -> String{
        return keychain.get(forKey.key) ?? ""
    }
    
    // MARK: DELETE DATA FROM KEYCHAIN
    public func deleteDataFromKeychain(forkey: KeychainKey){
        keychain.delete(forkey.key)
    }
    
    public func deleteAllValues() {
        keychain.clear()
    }
}
