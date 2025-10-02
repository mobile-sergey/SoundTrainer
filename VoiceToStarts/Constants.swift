//
//  Constants.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import SwiftUI
import Foundation

enum Constants {

    // MARK: - Уровни сложности
    enum Difficulty: String, CaseIterable {
        case easy = "Легкий"
        case medium = "Средний"
        case hard = "Сложный"
        
        var levelHeights: [CGFloat] {
            switch self {
            case .easy:
                return [0.35, 0.7, 1.0]
            case .medium:
                return [0.42, 0.75, 1.0]
            case .hard:
                return [0.45, 0.8, 1.0]
            }
        }
        
        var amplitudeThreshold: Float {
            switch self {
            case .easy:
                return 5.0
            case .medium:
                return 10.0
            case .hard:
                return 15.0
            }
        }
        
        var riseDistance: CGFloat {
            switch self {
            case .easy:
                return 10.0
            case .medium:
                return 8.0
            case .hard:
                return 6.0
            }
        }
        
        var riseSpeed: CGFloat {
            switch self {
            case .easy:
                return 100.0
            case .medium:
                return 120.0
            case .hard:
                return 150.0
            }
        }
        
        var fallSpeed: CGFloat {
            switch self {
            case .easy:
                return 50.0
            case .medium:
                return 60.0
            case .hard:
                return 80.0
            }
        }
    }

    // MARK: - Космонавт
    enum Cosmo {
        static let yOffset: CGFloat = 550  // Коррекция начальной позиции космонавта (внизу экрана)
        static let yMax: CGFloat = 800  // Максимальная позиция космонавта (вверху экрана)

    }

    // MARK: - Уровни
    enum Level {
        static let width: CGFloat = 0.25  // Относительная ширина уровней
        static let maxHeight: CGFloat = 0.9  // Максимальная относительная высота уровней
    }

    // MARK: - Анимации
    enum Anim {
        static let austronaut: String = "astronaut_animation"
        static let rocket: String = "rocket_animation"
        static let star: String = "star_animation_before"
        static let fireworks: String = "star_animation_after"
    }
}
