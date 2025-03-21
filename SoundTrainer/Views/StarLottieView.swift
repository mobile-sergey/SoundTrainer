//
//  StarLottieView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI
import Lottie

// Вспомогательное view для работы с Lottie
struct StarLottieView: UIViewRepresentable {
    let name: String
    var configure: ((LottieAnimationView) -> Void)?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
        configure?(animationView)
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Обновление не требуется, так как анимация управляется через configure
    }
}
