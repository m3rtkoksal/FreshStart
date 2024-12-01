//
//  LottieView.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//


import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    internal init(lottieFile: String, loopMode: LottieLoopMode? = .playOnce) {
        self.lottieFile = lottieFile
        self.loopMode = loopMode
    }
    
    let lottieFile: String
    let animationView = LottieAnimationView()
    let loopMode: LottieLoopMode?

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        animationView.animation = .named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1.8
        animationView.play()
        animationView.loopMode = loopMode ?? .playOnce
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
