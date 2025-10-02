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
    @State private var isSettingsPresented = false
    let onExit: () -> Void

    @State private var animatedY: CGFloat = 0
    @State private var lastLevelCheck: Int = 0

    init(onExit: @escaping () -> Void) {
        let gameSettings = GameSettings()
        _viewModel = StateObject(wrappedValue: GameViewModel(gameSettings: gameSettings))
        self.onExit = onExit
    }

    var body: some View {
        ZStack {
            BackgroundView().modifier(StarTwinkleModifier())

            // Уровни, звёзды и космонавт
            LevelsView(
                collectedStars: viewModel.state.collectedStars,
                onStarCollected: { level in
                    Task { @MainActor in
                        viewModel.collectStar(level: level)
                    }
                },
                difficulty: viewModel.state.difficulty,
                cosmoPosition: viewModel.state.cosmoPosition,
                currentLevel: viewModel.state.currentLevel
            )

            // Анимация фейерверка на весь экран
            if viewModel.state.shouldShowFireworks {
                AnimationView(name: Constants.Anim.fireworks)
                    .setLoopMode(.loop)
                    .setContentMode(.scaleAspectFill)
                    .edgesIgnoringSafeArea(.all)
            }
            
        }
        .onChange(of: viewModel.state.cosmoPosition.y) { newPosition in
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
            animatedY = viewModel.state.cosmoPosition.y
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
        .sheet(isPresented: $isSettingsPresented) {
            SettingsScreen(onBack: {
                isSettingsPresented = false
            })
        }
        .onDisappear {
            Task { @MainActor in
                viewModel.cleanup()
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isSettingsPresented = true
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func calculateDuration() -> Double {
        let distance = viewModel.state.difficulty.riseDistance
        let speed =
            viewModel.state.isSpeaking
            ? viewModel.state.difficulty.riseSpeed : viewModel.state.difficulty.fallSpeed
        return Double(distance) / Double(speed)
    }

    private func checkLevelProgress(newY: CGFloat) {
        guard viewModel.state.currentLevel < viewModel.state.difficulty.levelHeights.count,
              lastLevelCheck != viewModel.state.currentLevel
        else {
            return
        }

        let screenHeight = UIScreen.main.bounds.height
        let levelHeight = viewModel.state.difficulty.levelHeights[viewModel.state.currentLevel]
        // Вычисляем высоту столбца
        let columnHeight = screenHeight * levelHeight * Constants.Level.maxHeight
        // Космонавт должен быть на уровне верха столбца
        // targetPosition - это высота подъема космонавта от основания столбцов
        let targetPosition = columnHeight

        guard newY >= targetPosition else {
            return
        }

        lastLevelCheck = viewModel.state.currentLevel
        let currentLevel = viewModel.state.currentLevel
        let screenWidth = UIScreen.main.bounds.width
        
        Task { @MainActor in
            viewModel.processEvent(.levelReached(level: currentLevel))
            
            if currentLevel == viewModel.state.difficulty.levelHeights.count - 1 {
                viewModel.state.shouldShowFireworks = true
            }
        }
        
        // Анимация перехода на новый уровень
        withAnimation(.easeInOut(duration: 0.5)) {
            // Обновляем только вертикальную позицию космонавта
            // Горизонтальное позиционирование теперь обрабатывается в LevelsView
            viewModel.state.cosmoPosition = Constants.CosmoPosition(
                x: 0, // Горизонтальное смещение не нужно, так как currentLevel обрабатывается в LevelsView
                y: targetPosition
            )
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
