import AVFoundation
import Combine

class SpeechDetector {
    private var audioEngine: AVAudioEngine?
    private var isRecording = false
    private var cancellables = Set<AnyCancellable>()
    
    private let isUserSpeakingSubject = CurrentValueSubject<Bool, Never>(false)
    var isUserSpeakingPublisher: AnyPublisher<Bool, Never> {
        isUserSpeakingSubject.eraseToAnyPublisher()
    }
    
    func startRecording() {
        guard !isRecording else {
            print("Already recording")
            return
        }
        
        print("Starting recording...")
        
        do {
            // Настройка аудио сессии
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .measurement, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Инициализация аудио движка
            audioEngine = AVAudioEngine()
            guard let inputNode = audioEngine?.inputNode else {
                throw NSError(domain: "SpeechDetector", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not access input node"])
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            let bufferSize = AVAudioFrameCount(BalloonConstants.sampleRate)
            
            inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: recordingFormat) { [weak self] buffer, time in
                guard let self = self else { return }
                self.processAudioBuffer(buffer)
            }
            
            audioEngine?.prepare()
            try audioEngine?.start()
            isRecording = true
            
            print("Recording started successfully")
            
            // Запускаем таймер для проверки звука
            Timer.publish(every: BalloonConstants.soundCheckInterval, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.checkAudioLevel()
                }
                .store(in: &cancellables)
            
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
            stopRecording()
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        cancellables.removeAll()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
        isRecording = false
        
        try? AVAudioSession.sharedInstance().setActive(false)
        
        print("Recording stopped successfully")
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = UInt32(buffer.frameLength)
        
        // Вычисляем среднюю амплитуду
        var sum: Float = 0
        for i in 0..<Int(frameLength) {
            sum += abs(channelData[i])
        }
        
        let average = sum / Float(frameLength)
        let amplitude = average * 1000 // Масштабируем для соответствия с Android
        
        print("Amplitude: \(amplitude)")
        
        // Обновляем состояние говорения
        isUserSpeakingSubject.send(amplitude > BalloonConstants.amplitudeThreshold)
    }
    
    private func checkAudioLevel() {
        // Дополнительная логика проверки уровня звука, если необходимо
    }
    
    deinit {
        stopRecording()
    }
}

// Расширение для запроса разрешения на использование микрофона
extension SpeechDetector {
    static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}
