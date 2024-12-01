//
//  Color+Ext.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import SwiftUI
import UIKit

extension Color {
    static let borderGray = Color(ColorScheme.borderGray)
    static let solidGray = Color(ColorScheme.solidGray)
    static let solidWhite = Color(ColorScheme.solidWhite)
    static let topGreen = Color(ColorScheme.topGreen)
    static let bottomBlue = Color(ColorScheme.bottomBlue)
    static let babyBlue = Color(ColorScheme.babyBlue)
    static let lightTeal = Color(ColorScheme.lightTeal)
    static let progressBarPassive = Color(ColorScheme.progressBarPassive)
    static let cellBGGreen = Color(ColorScheme.cellBGGreen)
    static let buttonRed = Color(ColorScheme.buttonRed)
    static let otherGray = Color(ColorScheme.otherGray)
    static let menuBlack = Color(ColorScheme.menuBlack)

    
    //MARK: V2
    static let mkPurple = Color(ColorScheme.mkPurple)
    static let mkOrange = Color(ColorScheme.mkOrange)
    
    var uiColor: UIColor {
        UIColor(self)
    }
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    static func randomColor() -> Color {
        return Bool.random() ? Color.mkPurple : Color.mkOrange
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexValue = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()

        if hexValue.hasPrefix("#") {
            hexValue.remove(at: hexValue.startIndex)
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hexValue).scanHexInt64(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
           
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}



