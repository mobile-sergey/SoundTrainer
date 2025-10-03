//
//  GameViewModel.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import Combine
import SwiftUI

@MainActor
class GameViewModel: ObservableObject {
    @Published var state: GameState = .Initial
    private let speechDetector: SpeechDetector
    private var cancellables = Set<AnyCancellable>()
    private var isPreparingAudio = false
    private let gameSettings: GameSettings

    init(speechDetector: SpeechDetector = SpeechDetector(), gameSettings: GameSettings = GameSettings()) {
        self.speechDetector = speechDetector
        self.gameSettings = gameSettings
        resetGame()

        // Устанавливаем начальное положение космонавта в стартовой позиции
        state.cosmoPosition = Constants.CosmoPosition.zero
        prepareAudio()
        setupSpeechDetection()
        
        // Подписываемся на изменения сложности
        gameSettings.$difficulty
            .sink { [weak self] newDifficulty in
                self?.updateDifficulty(newDifficulty)
            }
            .store(in: &cancellables)
    }

    // Добавляем метод для предварительной подготовки аудио
    private func prepareAudio() {
        guard !isPreparingAudio else { return }
        isPreparingAudio = true

        Task.detached(priority: .userInitiated) {
            do {
                try await self.speechDetector.prepare()
                await MainActor.run {
                    self.isPreparingAudio = false
                }
            } catch {
                print("Error preparing audio: \(error.localizedDescription)")
                await MainActor.run {
                    self.isPreparingAudio = false
                }
            }
        }
    }

    private func setupSpeechDetection() {
        Task {
            let publisher = await speechDetector.isUserSpeakingPublisher

            publisher
                .debounce(
                    for: .milliseconds(100), scheduler: DispatchQueue.main
                )
                .receive(on: DispatchQueue.main)
                .sink { [weak self] soundVolume in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.processEvent(
                            .speakingChanged(soundVolume: soundVolume))
                    }
                }
                .store(in: &cancellables)
        }
    }

    func startDetecting() {
        Task { @MainActor in
            print("Starting sound detection")
            if !state.isDetectingActive {
                // Запускаем запись в фоновом потоке
                Task.detached(priority: .userInitiated) {
                    await self.speechDetector.startRecording()
                    await MainActor.run {
                        self.state.isDetectingActive = true
                    }
                }
            }
        }
    }

    func stopDetecting() {
        Task { @MainActor in
            print("Stopping sound detection")
            await speechDetector.stopRecording()
            state.isDetectingActive = false
        }
    }

    func processEvent(_ intent: GameEvent) {
        Task { @MainActor in
            switch intent {
            case .speakingChanged(let soundVolume):
                handleSpeakingState(soundVolume)
            case .levelReached(let level):
                handleLevelAchieved(level)
            case .resetGame:
                resetGame()
            }
        }
    }

    func collectStar(level: Int) {
        Task { @MainActor in
            if level < state.collectedStars.count {
                var newStars = state.collectedStars
                newStars[level] = true
                state.collectedStars = newStars
            }
        }
    }

    private func handleSpeakingState(_ soundVolume: Float) {
        guard state.currentLevel < state.difficulty.levelHeights.count else { return }

        let isSpeaking: Bool = soundVolume > state.difficulty.amplitudeThreshold
        let targetPosition = calculateNewPosition(
            state: state, isSpeaking: isSpeaking)

        // Создаем новый экземпляр GameState с обновленной позицией
        var newState = state
        newState.cosmoPosition = Constants.CosmoPosition(x: state.cosmoPosition.x, y: targetPosition)

        // Обновляем состояние
        state = newState

        print(
            "Speaking: \(isSpeaking), Position: \(state.cosmoPosition.y), Current Level: \(state.currentLevel), Sound Volume: \(soundVolume)"
        )
    }

    private func calculateNewPosition(state: GameState, isSpeaking: Bool) -> CGFloat {
        let targetY: CGFloat
        if isSpeaking {
            targetY = min(state.cosmoPosition.y + state.difficulty.riseSpeed * 0.1, UIScreen.main.bounds.height * Constants.Level.maxHeight)
        } else {
            targetY = max(state.cosmoPosition.y - state.difficulty.fallSpeed * 0.1, 0)
        }

        // Проверяем достижение уровней
        if checkLevel(0, targetY) {
            print("Достигнута высота для уровня 1: \(targetY)")
            processEvent(.levelReached(level: 0))
        } else if checkLevel(1, targetY) {
            print("Достигнута высота для уровня 2: \(targetY)")
            processEvent(.levelReached(level: 1))
        } else if checkLevel(2, targetY) {
            print("Достигнута высота для уровня 3: \(targetY)")
            processEvent(.levelReached(level: 2))
        }

        return targetY
    }

    private func checkLevel(_ level: Int, _ target: CGFloat) -> Bool {
        let screenHeight = UIScreen.main.bounds.height
        // Рассчитываем высоты уровней аналогично LevelsView
        let cosmoWidth: CGFloat = 50
        let levelHeights = state.difficulty.levelHeights.map { height in
            (screenHeight * height * Constants.Level.maxHeight)
        }
        return target >= levelHeights[level] - cosmoWidth * CGFloat((level + 1)) && state.currentLevel == level
    }

    private func handleLevelAchieved(_ level: Int) {
        print("Обработка достижения уровня: \(level)")
        var newState = state
        if level < state.collectedStars.count {
            // Отмечаем только текущую звезду как собранную
            var newStars = Array(
                repeating: false, count: state.difficulty.levelHeights.count)
            // Заполняем true все предыдущие звезды и текущую
            for i in 0...level {
                newStars[i] = true
            }
            newState.collectedStars = newStars

            // Увеличиваем текущий уровень
            newState.currentLevel = level + 1
            
            // Устанавливаем новую позицию космонавта
            let screenHeight = UIScreen.main.bounds.height
            let screenWidth = UIScreen.main.bounds.width
            let newY = screenHeight * state.difficulty.levelHeights[level] * Constants.Level.maxHeight
            let newX = -screenWidth / 2 + Constants.Level.width * screenWidth * (CGFloat(level + 1) + 0.5)
            
            newState.cosmoPosition = Constants.CosmoPosition(x: newX, y: newY)

            // Запускаем анимацию фейерверка только для последнего уровня
            if level == state.difficulty.levelHeights.count - 1 {
                newState.shouldShowFireworks = true
            }

            newState.shouldPlayStarAnimation = true

            state = newState
            print(
                "Level \(level) achieved. Stars: \(newState.collectedStars), Next level: \(state.currentLevel)"
            )
        }
    }

    private func updateStars(stars: [Bool], level: Int) -> [Bool] {
        var newStars = stars
        if level <= stars.count {
            newStars[level - 1] = true
        }
        return newStars
    }

    private func resetGame() {
        state = .Initial
        state.difficulty = gameSettings.difficulty
        state.currentLevel = 0
        state.cosmoPosition = Constants.CosmoPosition.zero
        
        state.collectedStars = Array(
            repeating: false, count: state.difficulty.levelHeights.count)
        print("Game state reset")
    }

    private func getCurrentLevelHeight(level: Int) -> CGFloat {
        guard level < state.difficulty.levelHeights.count else {
            return GameState.Initial.cosmoPosition.y
        }
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight * state.difficulty.levelHeights[level] * Constants.Level.maxHeight
    }

    private func updateDifficulty(_ newDifficulty: Constants.Difficulty) {
        state.difficulty = newDifficulty
        // Сбрасываем игру при смене сложности
        resetGame()
    }
    
    func setDifficulty(_ difficulty: Constants.Difficulty) {
        gameSettings.setDifficulty(difficulty)
    }

    func cleanup() {
        print("Cleaning up GameViewModel")
        Task {
            await speechDetector.stopRecording()
        }
    }

    deinit {
        // Просто логируем, очистка уже должна быть выполнена
        print("ViewModel cleared")
    }
}
