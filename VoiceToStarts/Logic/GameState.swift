//
//  BalloonState.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import Foundation

struct GameState: Equatable {
    var cosmoPosition: Constants.CosmoPosition // Позиция космонавта (x, y)
    var currentLevel: Int               // Текущий достигнутый уровень (индекс в списке уровней)
    var isSpeaking: Bool                // Флаг, указывающий, говорит ли пользователь в данный момент
    var isDetectingActive: Bool
    var collectedStars: [Bool]
    var shouldPlayStarAnimation: Bool
    var shouldShowFireworks: Bool
    var difficulty: Constants.Difficulty // Уровень сложности игры
    
    static var Initial: GameState {
        GameState(
            cosmoPosition: Constants.CosmoPosition.zero,
            currentLevel: 0,
            isSpeaking: false,
            isDetectingActive: false,
            collectedStars: Array(repeating: false, count: 3),
            shouldPlayStarAnimation: false,
            shouldShowFireworks: false,
            difficulty: .easy
        )
    }
}
