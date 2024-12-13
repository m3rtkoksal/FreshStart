//
//  LanguageHelper.swift
//  FreshStart
//
//  Created by Mert Köksal on 13.12.2024.
//

import Foundation

enum LanguageType: String, CaseIterable {
    case TR
    case EN
    case UK
    case ES
    case FR
    case DE
    
    var string: String {
        switch self {
        case .TR:
            return "Türkçe"
        case .EN:
            return "English"
        case .UK:
            return "Українська"
        case .ES:
            return "Español"
        case .FR:
            return "Français"
        case .DE:
            return "Deutsch"
        }
    }
    
    var shortString: String {
        rawValue
    }
}

final class LanguageHelper {
    static let shared = LanguageHelper()
    private let defaults = UserDefaults.standard
    var currentLanguage: LanguageType {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "selectedLanguage")
            Bundle.setLanguage(currentLanguage)
            ProfileManager.shared.setLanguage(currentLanguage.string)
        }
    }

    // Function to set language
    func setLanguage(_ language: LanguageType) {
        currentLanguage = language
    }

    var deviceLanguage: LanguageType {
        if let preferredLanguage = Locale.preferredLanguages.first {
            // Split the preferred language into language code and region (if available)
            let components = preferredLanguage.split(separator: "-")
            let languageCode = components.first ?? ""
            let regionCode = components.count > 1 ? components[1] : ""
            
            // Special case handling for "en-TR"
            if languageCode == "en" && regionCode == "TR" {
                return .EN
            }

            switch languageCode {
            case "tr":
                return .TR
            case "en":
                return .EN
            case "uk":
                return .UK
            case "es":
                return .ES
            case "fr":
                return .FR
            case "de":
                return .DE
            default:
                return .EN  // Default to English if unknown language code
            }
        }
        return .EN // Default to English if preferred language cannot be determined
    }

    private init() {
        currentLanguage = .EN
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = LanguageType(rawValue: savedLanguage) {
            currentLanguage = language
        } else {
            currentLanguage = deviceLanguage
        }
    }
}
