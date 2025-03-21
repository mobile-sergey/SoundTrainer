//
//  LottieView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI
import Lottie
import AVFoundation

// Вспомогательное view для отображения Lottie анимации
struct LottieView: UIViewRepresentable {
    let name: String
    
    private static var animationCache: [String: LottieAnimationView] = [:]
    
    func makeUIView(context: Context) -> LottieAnimationView {
        if let cachedAnimation = Self.animationCache[name] {
            if !cachedAnimation.isAnimationPlaying {
                cachedAnimation.play()
            }
            return cachedAnimation
        }
        
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        Self.animationCache[name] = animationView
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}
