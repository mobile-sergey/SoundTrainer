//
//  BalloonState.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import Foundation

struct BalloonState: Equatable {
    var balloonPosition: CGFloat  // Текущая позиция шарика, управляется анимацией
    var currentLevel: Int         // Текущий достигнутый уровень (индекс в списке уровней)
    var xOffset: CGFloat         // Смещение шарика по X при переходе на новый уровень
    var baseY: CGFloat          // Базовая позиция Y, от которой рассчитывается подъем/падение шарика
    var isSpeaking: Bool        // Флаг, указывающий, говорит ли пользователь в данный момент
    var isDetectingActive: Bool
    var collectedStars: [Bool]
    
    static var Initial: BalloonState {
        BalloonState(
            balloonPosition: BalloonConstants.baseY,
            currentLevel: 0,
            xOffset: 0,
            baseY: BalloonConstants.baseY,
            isSpeaking: false,
            isDetectingActive: false,
            collectedStars: Array(repeating: false, count: BalloonConstants.levelHeights.count)
        )
    }
}
