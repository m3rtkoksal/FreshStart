//
//  AppSwipeState.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import UIKit

class AppSwipeState {
  static let shared = AppSwipeState()
  var swipeEnabled = true    // << by default
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    // To make it works also with ScrollView
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard AppSwipeState.shared.swipeEnabled else { return false }
        return viewControllers.count > 1
    }
}



