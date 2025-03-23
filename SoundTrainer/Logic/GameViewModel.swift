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
    @Published var state: GameState = .Initial
    private let speechDetector: SpeechDetector
    private var cancellables = Set<AnyCancellable>()
    private var isPreparingAudio = false
    
    init(speechDetector: SpeechDetector = SpeechDetector()) {
        self.speechDetector = speechDetector
        resetGame()
        
        // Устанавливаем начальное положение ракеты
        state.position = 0 // Устанавливаем начальное значение position в 0
        prepareAudio()
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
        
        // Создаем новый экземпляр GameState с обновленной позицией
        var newState = state
        newState.position = targetPosition
        
        // Проверяем достижение уровня
        let currentLevelHeight = Constants.Level.y[newState.currentLevel] * UIScreen.main.bounds.height // Высота уровня в пикселях
        if newState.position >= currentLevelHeight && !newState.collectedStars[newState.currentLevel] {
            print("Достигнут уровень \(newState.currentLevel) на высоте \(currentLevelHeight)")
            
            // Запускаем анимацию сбора звезды
            newState.shouldPlayStarAnimation = true
            
            // Обрабатываем достижение уровня
            processEvent(.levelReached(level: newState.currentLevel))
            
            // Если это последняя звезда, показываем фейерверк
            if newState.currentLevel == Constants.Level.y.count - 1 {
                newState.shouldShowFireworks = true
            }
        }
        
        // Обновляем состояние
        state = newState // Присваиваем новый экземпляр state
        
        print("Speaking: \(isSpeaking), Position: \(state.position), Current Level: \(state.currentLevel), Sound Volume: \(soundVolume)")
    }
    
    private func handleLevelAchieved(_ level: Int) {
        var newState = state
        if level < state.collectedStars.count {
            newState.currentLevel = level
            newState.baseY = Constants.Level.y[level]
            newState.xOffset = Constants.Level.x[level]
            newState.shouldShowFireworks = true
            newState.shouldPlayStarAnimation = true
            collectStar(level: level)
            state = newState // Присваиваем новый экземпляр state
        }
        
        print("Level \(level) achieved. Stars: \(state.collectedStars)")
    }
    
    private func calculateNewPosition(state: GameState, isSpeaking: Bool) -> CGFloat {
//        _ = UIScreen.main.bounds.height // Получаем высоту экрана
        let targetY: CGFloat
        
        if isSpeaking {
            // Увеличиваем позицию при наличии звука
            targetY = min(state.position + Constants.Move.riseSpeed * 0.1, Constants.Cosmo.yMax) // Уменьшаем верхнюю границу до 850
        } else {
            // Уменьшаем позицию при отсутствии звука
            targetY = max(state.position - Constants.Move.fallSpeed * 0.1, 0) // Ограничиваем нижнюю границу
        }
        
        // Проверяем, достигли ли мы уровня для звезды
        if targetY >= Constants.Level.y[0] && state.currentLevel == 0 {
            processEvent(.levelReached(level: 1))
        } else if targetY >= Constants.Level.y[1] && state.currentLevel == 1 {
            processEvent(.levelReached(level: 2))
        } else if targetY >= Constants.Level.y[2] && state.currentLevel == 2 {
            processEvent(.levelReached(level: 3))
        }
        
        return targetY // Возвращаем новое значение позиции
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
