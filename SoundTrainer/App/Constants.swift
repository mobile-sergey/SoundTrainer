//
//  Constants.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI

enum Constants {
    
    // MARK: - Космонавт
    enum Cosmo {
        static let y: CGFloat = 320  // Начальная позиция космонавта (внизу экрана)
    }
    
    // MARK: - Уровни
    enum Level {
        static let width: CGFloat = 0.25                    // Относительная ширина уровней
        static let heights: [CGFloat] = [0.35, 0.7, 1.0]    // Относительные высоты уровней
        static let maxHeight: CGFloat = 0.9                 // Максимальная относительная высота уровней
        static let y: [CGFloat] = [200, 0, -200]            // Высоты уровней для звезд
        static let x: [CGFloat] = [-100, 0, 100]            // Смещения по X для каждой ступеньки
    }
    
    // MARK: - Движение
    enum Move {
        static let riseDistance: CGFloat = 10   // Расстояние подъема за одно обновление
        static let riseSpeed: CGFloat = 50      // Скорость подъема при звуке
        static let fallSpeed: CGFloat = 5       // Скорость падения при тишине
    }
    
    // MARK: - Звук
    enum Sound {
        static let amplitude: Float = 10                // Порог громкости для подъема
        static let сheckInterval: TimeInterval = 0.1    // Интервал проверки звука (100 мс)
    }

    // MARK: - Анимации
    enum Anim {
        static let austronaut: String = "astronaut_animation"
        static let rocket: String = "rocket_animation"
        static let star: String = "star_animation_before"
        static let fireworks: String = "star_animation_after"
    }
}
