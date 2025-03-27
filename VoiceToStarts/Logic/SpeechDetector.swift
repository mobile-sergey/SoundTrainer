//
//  SpeechDetector.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import CoreAudioTypes
import AVFoundation
import Combine

actor SpeechDetector {
    private var audioEngine: AVAudioEngine?
    private var isRecording = false
    private var cancellables = Set<AnyCancellable>()
    private var isPrepared = false
    private var timerCancellable: AnyCancellable?
    
    private let isUserSpeakingSubject = CurrentValueSubject<Float, Never>(0)
    var isUserSpeakingPublisher: AnyPublisher<Float, Never> {
        isUserSpeakingSubject.eraseToAnyPublisher()
    }
    
    func prepare() async throws {
        guard !isPrepared else { return }
        
        // Сначала настраиваем аудио сессию
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .mixWithOthers)
        try audioSession.setActive(true)
        
        // Создаем engine после настройки сессии
        audioEngine = AVAudioEngine()
        guard let inputNode = audioEngine?.inputNode else {
            throw NSError(domain: "SpeechDetector", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not access input node"])
        }
        
        // Создаем формат на основе настроек аудио сессии
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: audioSession.sampleRate,
            channels: AVAudioChannelCount(audioSession.inputNumberOfChannels),
            interleaved: false
        )
        
        guard let format = format else {
            throw NSError(domain: "SpeechDetector", code: -3, userInfo: [NSLocalizedDescriptionKey: "Could not create audio format"])
        }
        
        print("Audio format configuration:")
        print("Sample Rate: \(format.sampleRate)")
        print("Channel Count: \(format.channelCount)")
        print("Common Format: \(format.commonFormat.rawValue)")
        
        // Проверяем валидность формата
        guard format.sampleRate > 0 && format.channelCount > 0 else {
            throw NSError(domain: "SpeechDetector", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid audio format"])
        }
        
        // Используем меньший размер буфера
        let bufferSize = AVAudioFrameCount(4096) // Используем фиксированный размер буфера
        
        // Захватываем self как weak для предотвращения цикла удержания
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            guard let self = self else { return }
            Task {
                await self.processAudioBuffer(buffer)
            }
        }
        
        guard let engine = audioEngine else {
            throw NSError(domain: "SpeechDetector", code: -2, userInfo: [NSLocalizedDescriptionKey: "AudioEngine is nil"])
        }
        
        do {
            engine.prepare()
            try engine.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            throw error
        }
        
        isRecording = true
        isPrepared = true
    }
    
    func startRecording() async {
        do {
            if !isPrepared {
                try await prepare()
            }
            
            print("Starting recording...")
            
            // Создаем и сохраняем подписку на таймер
            timerCancellable = Timer.publish(every: Constants.Sound.сheckInterval, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self else { return }
                    Task {
                        await self.checkAudioLevel()
                    }
                }
            
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
            await stopRecording()
        }
    }
    
    func stopRecording() async {
        print("Stopping recording...")
        
        // Сначала отменяем таймер
        timerCancellable?.cancel()
        timerCancellable = nil
        
        guard isRecording else {
            print("Recording was not active")
            return
        }
        
        if let inputNode = audioEngine?.inputNode {
            print("Removing tap from input node")
            inputNode.removeTap(onBus: 0)
        }
        
        if let engine = audioEngine {
            print("Stopping audio engine")
            engine.stop()
        }
        
        audioEngine = nil
        isRecording = false
        isPrepared = false
        
        do {
            print("Deactivating audio session")
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivating audio session: \(error.localizedDescription)")
        }
        
        print("Recording stopped successfully")
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) async {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameLength = UInt32(buffer.frameLength)
        
        var sum: Float = 0
        for i in 0..<Int(frameLength) {
            sum += abs(channelData[i])
        }
        
        let average = sum / Float(frameLength)
        let amplitude = average * 1000
        
        // Отправляем результат
        isUserSpeakingSubject.send(amplitude)
    }
    
    private func checkAudioLevel() async {
        // Дополнительная логика проверки уровня звука, если необходимо
    }
    
    deinit {
        print("SpeechDetector deinit started")
        // Отменяем таймер синхронно в deinit
        timerCancellable?.cancel()
        timerCancellable = nil
        print("SpeechDetector deinit completed")
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
