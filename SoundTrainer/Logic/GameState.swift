//
//  BalloonState.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import Foundation

struct GameState: Equatable {
    var position: CGFloat               // Текущая позиция космонавта, управляется анимацией
    var currentLevel: Int               // Текущий достигнутый уровень (индекс в списке уровней)
    var xOffset: CGFloat                // Смещение космонавта по X при переходе на новый уровень
    var baseY: CGFloat                  // Базовая позиция Y, от которой рассчитывается подъем/падение космонавта
    var isSpeaking: Bool                // Флаг, указывающий, говорит ли пользователь в данный момент
    var isDetectingActive: Bool
    var collectedStars: [Bool]
    var shouldPlayStarAnimation: Bool
    var shouldShowFireworks: Bool
    
    static var Initial: GameState {
        GameState(
            position: Constants.Cosmo.y,
            currentLevel: 0,
            xOffset: -150,
            baseY: Constants.Cosmo.y,
            isSpeaking: false,
            isDetectingActive: false,
            collectedStars: Array(repeating: false, count: Constants.Level.y.count),
            shouldPlayStarAnimation: false,
            shouldShowFireworks: false
        )
    }
}
