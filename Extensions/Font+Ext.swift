//
//  Font+Ext.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import SwiftUI

extension Font {
    enum MontserratFont {
        case bold
        case semiBold
        case medium
        case regular
        case light
        
        var name: String {
            switch self {
            case .bold:
                return "Montserrat-Bold"
            case .semiBold:
                return "Montserrat-SemiBold"
            case .medium:
                return "Montserrat-Medium"
            case .regular:
                return "Montserrat-Regular"
            case .light:
                return "Montserrat-Light"
            }
        }
    }
    
    static func montserrat(_ type: MontserratFont, size: CGFloat = 24) -> Font {
        .custom(type.name, size: size)
    }
}


