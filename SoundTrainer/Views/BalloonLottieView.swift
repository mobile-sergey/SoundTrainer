//
//  BalloonLottieView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI
import Lottie

struct BalloonLottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        
        animationView.configuration.renderingEngine = .mainThread
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
