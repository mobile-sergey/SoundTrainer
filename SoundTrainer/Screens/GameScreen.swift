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

            // Анимация фейерверка на весь экран
            if viewModel.state.shouldShowFireworks {
                AnimationView(name: Constants.Anim.fireworks)
                    .setLoopMode(.loop)
                    .setContentMode(.scaleAspectFill)
                    .edgesIgnoringSafeArea(.all)
            }
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
        else {
            return
        }

        lastLevelCheck = viewModel.state.currentLevel
        let currentLevel = viewModel.state.currentLevel
        let screenWidth = UIScreen.main.bounds.width
        
        // Анимация перехода на новый уровень
        withAnimation(.easeInOut(duration: 0.5)) {
            // Анимация перемещения космонавта к звезде текущего уровня
            viewModel.state.position = Constants.Level.y[currentLevel]
            viewModel.state.xOffset = -screenWidth/2 + Constants.Level.width * screenWidth/2
        }

        Task { @MainActor in
            viewModel.processEvent(.levelReached(level: currentLevel))
            
            // Если достигнут последний уровень, можно добавить дополнительную логику
            if currentLevel == Constants.Level.y.count - 1 {
                // Например, показать поздравление или запустить особую анимацию
                viewModel.state.shouldShowFireworks = true
            }
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
