import SwiftUI
import Combine

@MainActor
class GameViewModel: ObservableObject {
    @Published private(set) var state: BalloonState = .Initial
    private let speechDetector: SpeechDetector
    private var cancellables = Set<AnyCancellable>()
    
    init(speechDetector: SpeechDetector = SpeechDetector()) {
        self.speechDetector = speechDetector
        resetGame()
        
        // Подписываемся на изменения состояния речи с правильной обработкой потока
        speechDetector.isUserSpeakingPublisher
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSpeaking in
                guard let self = self else { return }
                Task { @MainActor in
                    self.processIntent(.speakingChanged(isSpeaking: isSpeaking))
                }
            }
            .store(in: &cancellables)
    }
    
    func processIntent(_ intent: BalloonIntent) {
        Task { @MainActor in
            switch intent {
            case .speakingChanged(let isSpeaking):
                handleSpeakingState(isSpeaking)
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
                speechDetector.startRecording()
            }
            state.isDetectingActive = true
        }
    }
    
    func stopDetecting() {
        Task { @MainActor in
            print("Stopping sound detection")
            speechDetector.stopRecording()
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
    
    private func handleSpeakingState(_ isSpeaking: Bool) {
        guard state.currentLevel < BalloonConstants.lottieHeights.count else { return }
        
        let newPosition = calculateNewPosition(state: state, isSpeaking: isSpeaking)
        state.isSpeaking = isSpeaking
        state.balloonPosition = newPosition
    }
    
    private func handleLevelAchieved(_ level: Int) {
        guard level < BalloonConstants.lottieHeights.count else { return }
        
        let newStars = updateStars(stars: state.collectedStars, level: level)
        state.currentLevel = level + 1
        state.baseY = BalloonConstants.lottieHeights[level]
        state.xOffset = BalloonConstants.lottieStairOffsets[level]
        state.collectedStars = newStars
        
        print("Level \(level) achieved. Stars: \(newStars)")
    }
    
    private func calculateNewPosition(state: BalloonState, isSpeaking: Bool) -> CGFloat {
        let targetY: CGFloat
        if isSpeaking {
            targetY = state.balloonPosition - BalloonConstants.riseDistance
        } else {
            targetY = state.balloonPosition + BalloonConstants.fallSpeed
        }
        
        let minY = getCurrentLevelHeight(level: state.currentLevel)
        return min(max(targetY, minY), state.baseY)
    }
    
    private func updateStars(stars: [Bool], level: Int) -> [Bool] {
        let correctedLevel = BalloonConstants.lottieHeights.count - 1 - level
        var newStars = stars
        if correctedLevel < stars.count {
            newStars[correctedLevel] = true
        }
        return newStars
    }
    
    private func resetGame() {
        state = .Initial
        state.collectedStars = Array(repeating: false, count: BalloonConstants.levelHeights.count)
        print("Game state reset")
    }
    
    private func getCurrentLevelHeight(level: Int) -> CGFloat {
        guard level < BalloonConstants.lottieHeights.count else {
            return BalloonState.Initial.baseY
        }
        return BalloonConstants.lottieHeights[level]
    }
    
    deinit {
        Task { @MainActor in
            stopDetecting()
        }
        print("ViewModel cleared")
    }
} 
