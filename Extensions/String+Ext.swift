//
//  String+Ext.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import Foundation
import UIKit
import SwiftUICore

extension String {
    func trimmingAllSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return components(separatedBy: characterSet).joined()
    }
    
    func iconName() -> String {
        switch self {
        case "Vegan":
            return "vegan"
        case "Vegetarian":
            return "vegetarian"
        case "Pescatarian":
            return "pescatarian"
        case "Flexitarian":
            return "flexitarian"
        case "No Red Meat":
            return "no-red-meat"
        case "Poultry Only":
            return "poultry-only"
        case "Normal":
            return "normal"
        case "Gain weight":
            return "gainFat"
        case "Gain muscle":
            return "gainMuscle"
        default:
            return "defaultIcon" // Placeholder or default image
        }
    }
}

extension String {
    func localized() -> String {
        return Bundle.localized.localizedString(forKey: self, value: nil, table: nil)
    }
    
    func localized(_ arguments: CVarArg...) -> String {
        let format = Bundle.localized.localizedString(forKey: self, value: nil, table: nil)
        return String(format: format, arguments: arguments)
    }
}

extension String {
    // Helper function to calculate the width of the text with a given font
    func width(using font: Font) -> CGFloat {
        let uiFont = font.toUIFont(size: 14)  // Default size, you can adjust based on needs
        let attributes: [NSAttributedString.Key: Any] = [.font: uiFont]
        let size = (self as NSString).size(withAttributes: attributes)
        return size.width
    }
}
