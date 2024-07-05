//
//  LottieView.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 03/07/24.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    func makeUIView(context: Context) -> Lottie.LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        animationView.play()
        return animationView
    }

    

    func updateUIView(_ uiView: Lottie.LottieAnimationView, context: Context) {
        
    }
}
