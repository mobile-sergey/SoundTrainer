//
//  GameViewModel.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published private(set) var state: GameState = .Initial
    private let speechDetector: SpeechDetector
    private var cancellables = Set<AnyCancellable>()
    private var isPreparingAudio = false
    
    init(speechDetector: SpeechDetector = SpeechDetector()) {
        self.speechDetector = speechDetector
        resetGame()
        
        // Подготавливаем аудио заранее
        prepareAudio()
        
        // Настраиваем подписку на publisher в отдельной задаче
        setupSpeechDetection()
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
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] soundVolume in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.processEvent(.speakingChanged(soundVolume: soundVolume))
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
        guard state.currentLevel < Constants.Level.y.count else { return }
        
        let isSpeaking: Bool = soundVolume > Constants.Sound.amplitude
        let targetPosition = calculateNewPosition(state: state, isSpeaking: isSpeaking)
        
        // Обновляем позицию
        state.position = targetPosition
        
        // Проверяем достижение уровня
        let currentLevelHeight = Constants.Level.y[state.currentLevel] * UIScreen.main.bounds.height // Высота уровня в пикселях
        if state.position >= currentLevelHeight && !state.collectedStars[state.currentLevel] {
            print("Достигнут уровень \(state.currentLevel) на высоте \(currentLevelHeight)")
            
            // Запускаем анимацию сбора звезды
            state.shouldPlayStarAnimation = true
            
            // Обрабатываем достижение уровня
            processEvent(.levelReached(level: state.currentLevel))
            
            // Если это последняя звезда, показываем фейерверк
            if state.currentLevel == Constants.Level.y.count - 1 {
                state.shouldShowFireworks = true
            }
        }
        
        // Обновляем состояние
        state.isSpeaking = isSpeaking
        
        print("Speaking: \(isSpeaking), Position: \(state.position), Current Level: \(state.currentLevel), Sound Volume: \(soundVolume)")
    }
    
    private func handleLevelAchieved(_ level: Int) {
        guard level < Constants.Level.y.count else { return }
        
        let newStars = updateStars(stars: state.collectedStars, level: level)
        state.currentLevel = level + 1
        state.baseY = Constants.Level.y[level]
        state.xOffset = Constants.Level.x[level]
        state.collectedStars = newStars
        
        print("Level \(level) achieved. Stars: \(newStars)")
    }
    
    private func calculateNewPosition(state: GameState, isSpeaking: Bool) -> CGFloat {
        let targetY: CGFloat
        if isSpeaking {
            // Увеличиваем позицию при наличии звука
            targetY = state.position + Constants.Move.riseSpeed * 0.1 // Увеличиваем позицию с использованием riseSpeed
        } else {
            // Уменьшаем позицию при отсутствии звука
            targetY = state.position - Constants.Move.fallSpeed * 0.1 // Уменьшаем позицию с использованием fallSpeed
        }
        
        // Убираем ограничение по верхней границе, чтобы космонавт мог подниматься выше
        return targetY // Возвращаем новое значение позиции
    }
    
    private func updateStars(stars: [Bool], level: Int) -> [Bool] {
        let correctedLevel = Constants.Level.y.count - 1 - level
        var newStars = stars
        if correctedLevel < stars.count {
            newStars[correctedLevel] = true
        }
        return newStars
    }
    
    private func resetGame() {
        state = .Initial
        state.collectedStars = Array(repeating: false, count: Constants.Level.y.count)
        print("Game state reset")
    }
    
    private func getCurrentLevelHeight(level: Int) -> CGFloat {
        guard level < Constants.Level.y.count else {
            return GameState.Initial.baseY
        }
        return Constants.Level.y[level]
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
