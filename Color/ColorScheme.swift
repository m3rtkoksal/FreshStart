//
//  ColorScheme.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import UIKit

//MARK: Colors for light dark mode
struct ColorScheme {
    static func color(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor.dynamicColor(light: light, dark: dark)
    }
    static var borderGray: UIColor {
        return color(light:UIColor.init(hex: "#696969"),
                     dark: UIColor.init(hex: "#696969"))
    }
    static var solidGray: UIColor {
        return color(light:UIColor.init(hex: "#8B858D"),
                     dark: UIColor.init(hex: "#8B858D"))
    }
    static var solidWhite: UIColor {
        return color(light:UIColor.init(hex: "#FFFFFF"),
                     dark: UIColor.init(hex: "#FFFFFF"))
    }
    static var topGreen: UIColor {
        return color(light: UIColor.init(hex: "#98FFC7"),
                     dark: UIColor.init(hex: "#98FFC7"))
    }
    static var bottomBlue: UIColor {
        return color(light: UIColor.init(hex: "#87EBFA"),
                     dark: UIColor.init(hex: "#87EBFA"))
    }
    static var babyBlue: UIColor {
        return color(light: UIColor.init(hex: "#B9F0FC"),
                     dark: UIColor.init(hex: "#B9F0FC"))
    }
    static var lightTeal: UIColor {
        return color(light: UIColor.init(hex: "#F8FFFC"),
                     dark: UIColor.init(hex: "#F8FFFC"))
    }
    static var progressBarPassive: UIColor {
        return color(light: UIColor.init(hex: "#D1D1D1"),
                     dark: UIColor.init(hex: "#D1D1D1"))
    }
    static var cellBGGreen: UIColor {
        return color(light: UIColor.init(hex: "#D0FCE9"),
                     dark: UIColor.init(hex: "#D0FCE9"))
    }
    static var otherGray: UIColor {
        return color(light:UIColor.init(hex: "#999999"),
                     dark: UIColor.init(hex: "#999999"))
    }
    static var menuBlack: UIColor {
        return color(light:UIColor.init(hex: "#351E52"),
                     dark: UIColor.init(hex: "#351E52"))
    }
    static var buttonRed: UIColor {
        return color(light: UIColor.init(hex: "#EC7666"),
                     dark: UIColor.init(hex: "#EC7666"))
    }
    //MARK: V2
    
    static var mkOrange: UIColor {
        return color(light: UIColor.init(hex: "#FF7300"),
                     dark: UIColor.init(hex: "#FF7300"))
    }
    static var mkPurple: UIColor {
        return color(light: UIColor.init(hex: "#975ED5"),
                     dark: UIColor.init(hex: "#975ED5"))
    }
}


