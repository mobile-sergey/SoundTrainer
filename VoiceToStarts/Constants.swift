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
        let name: String // Название уровня сложности для отображения пользователю
        let levelHeights: [CGFloat] // Относительные высоты уровней (0.0-1.0), где 1.0 - максимальная высота экрана
        let amplitudeThreshold: Float // Порог громкости звука для активации подъема космонавта (в децибелах)
        let riseSpeed: CGFloat // Скорость подъема космонавта при говорении (пикселей в секунду)
        let fallSpeed: CGFloat // Скорость падения космонавта при молчании (пикселей в секунду)
        let riseDistance: CGFloat // Расстояние подъема за одно обновление анимации (пиксели)
        let checkInterval: TimeInterval // Интервал проверки звука для определения говорения (секунды)
        
        static let easy = Difficulty(
            name: "Легкий", // Простой уровень для начинающих
            levelHeights: [0.25, 0.5, 0.75], // Низкие уровни - легко достичь, последний уровень не максимальный
            amplitudeThreshold: 5.0, // Низкий порог - реагирует на тихий звук
            riseSpeed: 100.0, // Медленный подъем - легче контролировать
            fallSpeed: 30.0, // Медленное падение - больше времени на реакцию
            riseDistance: 10.0, // Большое расстояние за шаг - плавное движение
            checkInterval: 0.1 // Стандартная частота проверки звука
        )
        
        static let medium = Difficulty(
            name: "Средний", // Умеренный уровень сложности
            levelHeights: [0.3, 0.6, 0.9], // Средние уровни - требует больше усилий, последний уровень ниже максимума
            amplitudeThreshold: 10.0, // Средний порог - нужен более громкий звук
            riseSpeed: 120.0, // Умеренная скорость подъема
            fallSpeed: 70.0, // Быстрее падает - сложнее удерживать высоту
            riseDistance: 8.0, // Среднее расстояние за шаг
            checkInterval: 0.1 // Стандартная частота проверки звука
        )
        
        static let hard = Difficulty(
            name: "Сложный", // Высокий уровень сложности для опытных игроков
            levelHeights: [0.4, 0.7, 1.0], // Высокие уровни - требует максимальных усилий, последний уровень почти максимальный
            amplitudeThreshold: 15.0, // Высокий порог - нужен очень громкий звук
            riseSpeed: 150.0, // Быстрый подъем - сложнее контролировать
            fallSpeed: 120.0, // Очень быстрое падение - очень сложно удерживать высоту
            riseDistance: 6.0, // Малое расстояние за шаг - более резкие движения
            checkInterval: 0.1 // Стандартная частота проверки звука
        )
        
        static let allCases: [Difficulty] = [.easy, .medium, .hard]
    }
    
    // MARK: - Космонавт
    struct CosmoPosition: Equatable {
        let x: CGFloat
        let y: CGFloat
        
        static let zero = CosmoPosition(x: 0, y: 0)
    }
    
    enum Cosmo {
        static let width: CGFloat = 180
        static let height: CGFloat = 180
    }
    
    // MARK: - Уровни
    enum Level {
        static let width: CGFloat = 0.25  // Относительная ширина уровней
        static let maxHeight: CGFloat = 0.9  // Максимальная относительная высота уровней
    }
    
    // MARK: - Звезды
    enum Star {
        static let distanceFromColumn: CGFloat = 0.1  // Расстояние от столбца (10% от высоты экрана)
    }
    
    // MARK: - Анимации
    enum Anim {
        static let austronaut: String = "astronaut_animation"
        static let rocket: String = "rocket_animation"
        static let star: String = "star_animation_before"
        static let fireworks: String = "star_animation_after"
    }
}
