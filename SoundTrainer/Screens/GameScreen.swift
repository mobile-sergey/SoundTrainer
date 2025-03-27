//
//  GameScreen.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import SwiftUI

struct GameScreen: View {
    @StateObject private var viewModel: GameViewModel
    @State private var showMicrophoneAlert = false
    let onExit: () -> Void

    @State private var animatedY: CGFloat = 0
    @State private var lastLevelCheck: Int = 0

    init(onExit: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel())
        self.onExit = onExit
    }

    var body: some View {
        ZStack {
            BackgroundView().modifier(StarTwinkleModifier())

            // Уровни и звёзды
            LevelsView(
                collectedStars: viewModel.state.collectedStars,
                onStarCollected: { level in
                    Task { @MainActor in
                        viewModel.collectStar(level: level)
                    }
                }
            )

            // Основная анимация космонавта
            AnimationView(name: Constants.Anim.austronaut)
                .setLoopMode(.loop)
                .setContentMode(.scaleAspectFill)
                .frame(width: 180, height: 180)
                .offset(
                    x: viewModel.state.xOffset,
                    y: UIScreen.main.bounds.height - Constants.Cosmo.yOffset
                        - viewModel.state.position)

        }
        .onChange(of: viewModel.state.position) { newPosition in
            withAnimation(.linear(duration: 0.1)) {
                animatedY = newPosition
            }
        }
        .onChange(of: animatedY) { newY in
            checkLevelProgress(newY: newY)
        }
        .animation(.default, value: viewModel.state)
        .transaction { transaction in
            transaction.animation = .default
        }
        .onAppear {
            animatedY = viewModel.state.position
            // Запрашиваем разрешение перед началом записи
            SpeechDetector.requestMicrophonePermission { granted in
                if granted {
                    Task { @MainActor in
                        viewModel.startDetecting()
                    }
                } else {
                    showMicrophoneAlert = true
                }
            }
        }
        .alert(
            "Требуется доступ к микрофону", isPresented: $showMicrophoneAlert
        ) {
            Button("Открыть настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Отмена", role: .cancel) {
                // Возвращаемся на предыдущий экран, так как без микрофона игра не работает
                onExit()
            }
        } message: {
            Text(
                "Для работы приложения необходим доступ к микрофону. Пожалуйста, предоставьте разрешение в настройках."
            )
        }
        .onDisappear {
            Task { @MainActor in
                viewModel.cleanup()
            }
        }
    }

    private func calculateDuration() -> Double {
        let distance = Constants.Move.riseDistance
        let speed =
            viewModel.state.isSpeaking
            ? Constants.Move.riseSpeed : Constants.Move.fallSpeed
        return Double(distance) / Double(speed)
    }

    private func checkLevelProgress(newY: CGFloat) {
        guard viewModel.state.currentLevel < Constants.Level.y.count,
            lastLevelCheck != viewModel.state.currentLevel,
            newY >= Constants.Level.y[viewModel.state.currentLevel]
                * UIScreen.main.bounds.height
        else {
            return
        }

        lastLevelCheck = viewModel.state.currentLevel

        // Запуск анимации фейерверков при достижении уровня
        launchFireworks(for: viewModel.state.currentLevel)

        Task { @MainActor in
            viewModel.processEvent(
                .levelReached(level: viewModel.state.currentLevel))
            // Обновление собранных звёзд
            viewModel.state.collectedStars = Array(
                repeating: false, count: Constants.Level.y.count)  // Сброс звёзд
            viewModel.state.collectedStars[viewModel.state.currentLevel] = true  // Отметить текущую звезду как собранную
        }
    }

    private func launchFireworks(for level: Int) {
        // Логика запуска анимации фейерверков для соответствующего уровня
        // Например, можно использовать специальный View для анимации
        //        FireworksView()
    }
}

#Preview {
    GameScreen(onExit: {})
}
