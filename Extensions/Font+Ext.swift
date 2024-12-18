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
    
    func toUIFont(size: CGFloat) -> UIFont {
        UIFont(name: self.name(for: size), size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    private func name(for size: CGFloat) -> String {
        switch self {
        case .montserrat(.bold): return "Montserrat-Bold"
        case .montserrat(.semiBold): return "Montserrat-SemiBold"
        case .montserrat(.medium): return "Montserrat-Medium"
        case .montserrat(.regular): return "Montserrat-Regular"
        case .montserrat(.light): return "Montserrat-Light"
        default: return "System"
        }
    }
}


