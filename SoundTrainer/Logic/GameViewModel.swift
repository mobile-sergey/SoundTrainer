import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published private(set) var state: BalloonState = .Initial
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
    
    private func setupSpeechDetection() {
        Task {
            let publisher = await speechDetector.isUserSpeakingPublisher
            
            publisher
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] soundVolume in
                    guard let self = self else { return }
                    Task { @MainActor in
                        self.processIntent(.speakingChanged(soundVolume: soundVolume))
                    }
                }
                .store(in: &cancellables)
        }
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
    
    func processIntent(_ intent: BalloonIntent) {
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
        guard state.currentLevel < Constants.lottieHeights.count else { return }
        
        let isSpeaking: Bool = soundVolume > Constants.amplitudeThreshold
        let newPosition = calculateNewPosition(state: state, isSpeaking: isSpeaking)
        
        // Проверяем достижение уровня
        let currentLevelHeight = Constants.lottieHeights[state.currentLevel]
        if newPosition <= currentLevelHeight && !state.collectedStars[state.currentLevel] {
            print("Достигнут уровень \(state.currentLevel) на высоте \(currentLevelHeight)")
            
            // Запускаем анимацию сбора звезды
            state.shouldPlayStarAnimation = true
            
            // Обрабатываем достижение уровня
            processIntent(.levelReached(level: state.currentLevel))
            
            // Если это последняя звезда, показываем фейерверк
            if state.currentLevel == Constants.lottieHeights.count - 1 {
                state.shouldShowFireworks = true
            }
        }
        
        // Обновляем состояние
        state.isSpeaking = isSpeaking
        state.balloonPosition = newPosition
        
        print("Speaking: \(isSpeaking), Position: \(newPosition), Current Level: \(state.currentLevel), Sound Volume: \(soundVolume)")
    }
    
    private func handleLevelAchieved(_ level: Int) {
        guard level < Constants.lottieHeights.count else { return }
        
        let newStars = updateStars(stars: state.collectedStars, level: level)
        state.currentLevel = level + 1
        state.baseY = Constants.lottieHeights[level]
        state.xOffset = Constants.lottieStairOffsets[level]
        state.collectedStars = newStars
        
        print("Level \(level) achieved. Stars: \(newStars)")
    }
    
    private func calculateNewPosition(state: BalloonState, isSpeaking: Bool) -> CGFloat {
        let targetY: CGFloat
        if isSpeaking {
            // Движение вверх при громком звуке
            targetY = state.balloonPosition - Constants.riseDistance
        } else {
            // Падение при тишине
            targetY = state.balloonPosition + Constants.fallSpeed
        }
        
        // Ограничиваем только нижнюю границу движения
        let maxY = state.baseY  // Нижняя граница
        let minY: CGFloat = 0   // Верхняя граница (верх экрана)
        
        return min(max(targetY, minY), maxY)
    }
    
    private func updateStars(stars: [Bool], level: Int) -> [Bool] {
        let correctedLevel = Constants.lottieHeights.count - 1 - level
        var newStars = stars
        if correctedLevel < stars.count {
            newStars[correctedLevel] = true
        }
        return newStars
    }
    
    private func resetGame() {
        state = .Initial
        state.collectedStars = Array(repeating: false, count: Constants.levelHeights.count)
        print("Game state reset")
    }
    
    private func getCurrentLevelHeight(level: Int) -> CGFloat {
        guard level < Constants.lottieHeights.count else {
            return BalloonState.Initial.baseY
        }
        return Constants.lottieHeights[level]
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
