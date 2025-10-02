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
    struct Difficulty: Equatable, Identifiable {
        let id = UUID()
        let name: String
        let levelHeights: [CGFloat]
        let amplitudeThreshold: Float
        let riseSpeed: CGFloat
        let fallSpeed: CGFloat
        let riseDistance: CGFloat
        let checkInterval: TimeInterval
        
        static let easy = Difficulty(
            name: "Легкий",
            levelHeights: [0.35, 0.7, 1.0],
            amplitudeThreshold: 5.0,
            riseSpeed: 100.0,
            fallSpeed: 50.0,
            riseDistance: 10.0,
            checkInterval: 0.1
        )
        
        static let medium = Difficulty(
            name: "Средний",
            levelHeights: [0.42, 0.75, 1.0],
            amplitudeThreshold: 10.0,
            riseSpeed: 120.0,
            fallSpeed: 60.0,
            riseDistance: 8.0,
            checkInterval: 0.1
        )
        
        static let hard = Difficulty(
            name: "Сложный",
            levelHeights: [0.45, 0.8, 1.0],
            amplitudeThreshold: 15.0,
            riseSpeed: 150.0,
            fallSpeed: 80.0,
            riseDistance: 6.0,
            checkInterval: 0.1
        )
        
        static let allCases: [Difficulty] = [.easy, .medium, .hard]
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
