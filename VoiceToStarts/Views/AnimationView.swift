//
//  AnimationView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import Lottie
import SwiftUI

struct AnimationView: UIViewRepresentable {
    // MARK: - Properties
    let name: String
    var loopMode: LottieLoopMode = .loop
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var animationSpeed: CGFloat = 1.0
    var shouldPlay: Bool = true
    var onAnimationComplete: (() -> Void)?

    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView()
        context.coordinator.animationView = animationView
        context.coordinator.onAnimationComplete = onAnimationComplete

        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
            animationView.loopMode = loopMode
            animationView.contentMode = contentMode
            animationView.animationSpeed = animationSpeed

            // Настраиваем рендеринг на главном потоке
            animationView.configuration.renderingEngine = .mainThread

            if shouldPlay {
                animationView.play()
            }

            // Добавляем обработчик завершения
            animationView.play { finished in
                if finished {
                    onAnimationComplete?()
                }
            }

            // Настройка констрейнтов
            animationView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(animationView)

            NSLayoutConstraint.activate([
                animationView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor),
                animationView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor),
                animationView.topAnchor.constraint(equalTo: view.topAnchor),
                animationView.bottomAnchor.constraint(
                    equalTo: view.bottomAnchor),
            ])
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else {
            return
        }

        // Обновляем параметры если они изменились
        if animationView.loopMode != loopMode {
            animationView.loopMode = loopMode
        }
        if animationView.contentMode != contentMode {
            animationView.contentMode = contentMode
        }
        if animationView.animationSpeed != animationSpeed {
            animationView.animationSpeed = animationSpeed
        }

        // Управляем воспроизведением
        if shouldPlay && !animationView.isAnimationPlaying {
            animationView.play()
        } else if !shouldPlay && animationView.isAnimationPlaying {
            animationView.pause()
        }
    }

    // MARK: - Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var animationView: LottieAnimationView?
        var onAnimationComplete: (() -> Void)?
    }
}

// MARK: - Convenience Modifiers
extension AnimationView {
    func setLoopMode(_ mode: LottieLoopMode) -> AnimationView {
        var view = self
        view.loopMode = mode
        return view
    }

    func setContentMode(_ mode: UIView.ContentMode) -> AnimationView {
        var view = self
        view.contentMode = mode
        return view
    }

    func setSpeed(_ speed: CGFloat) -> AnimationView {
        var view = self
        view.animationSpeed = speed
        return view
    }

    func setPlaying(_ isPlaying: Bool) -> AnimationView {
        var view = self
        view.shouldPlay = isPlaying
        return view
    }

    func onAnimationComplete(_ completion: @escaping () -> Void)
        -> AnimationView
    {
        var view = self
        view.onAnimationComplete = completion
        return view
    }
}

// MARK: - Preview
#Preview {
    AnimationView(name: Constants.Anim.austronaut)
        .setLoopMode(.playOnce)
        .setContentMode(.scaleAspectFill)
        .setSpeed(1.5)
        .setPlaying(true)
        .frame(width: 200, height: 200)
}
