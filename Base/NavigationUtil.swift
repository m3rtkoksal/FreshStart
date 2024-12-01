//
//  NavigationUtil.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI

struct NavigationUtil {
    static func popToRootView() {
        guard let window = UIApplication.shared.windows.first else { return }
        if let rootViewController = window.rootViewController as? UINavigationController {
            rootViewController.popToRootViewController(animated: true)
        }
    }
}
