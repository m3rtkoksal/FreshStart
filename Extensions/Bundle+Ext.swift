//
//  Bundle+Ext.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.12.2024.
//

import Foundation

extension Bundle {
    private static var bundle: Bundle!

    static func setLanguage(_ language: LanguageType) {
        let languageCode = language.rawValue.lowercased()
        
        // Attempt to load the language based on the language code (e.g., "tr", "en")
        if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj") {
            print("Path found for \(language): \(path)")  // Debug print
            if let languageBundle = Bundle(path: path) {
                print("Successfully loaded bundle for \(language)")
                bundle = languageBundle
            } else {
                print("Failed to load language bundle for \(language)")  // Debug print
                bundle = Bundle.main
            }
        } else {
            // If direct language code (e.g., "tr") fails, try checking region-specific codes (e.g., "en-TR", "tr-TR")
            if let path = Bundle.main.path(forResource: "\(languageCode)-TR", ofType: "lproj") {
                print("Path found for \(language) with region: \(path)")  // Debug print
                if let languageBundle = Bundle(path: path) {
                    print("Successfully loaded bundle for \(language) with region")
                    bundle = languageBundle
                } else {
                    print("Failed to load language bundle with region for \(language)")  // Debug print
                    bundle = Bundle.main
                }
            } else {
                // Fallback to default language if region-specific language is not found
                print("Region-specific language bundle not found, falling back to default")  // Debug print
                bundle = Bundle.main
            }
        }
    }

    // Return the localized bundle
    static var localized: Bundle {
        return bundle ?? Bundle.main
    }
}
