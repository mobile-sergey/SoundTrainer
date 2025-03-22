//
//  Constants.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI

enum Constants {
    
    // MARK: - Начальное расположение
    
    static let baseY: CGFloat = 250  // Начальная позиция космонавта (внизу экрана)
    
    // Расположение звёзд
    static let stairY: [CGFloat] = [
        330,   // Высота первой звезды (верхний уровень)
        540,   // Высота второй звезды (средний уровень)
        750    // Высота третьей звезды (нижний уровень)
    ]
    
    // Высоты уровней для звезд
    static let levelY: [CGFloat] = [
        200,    // Высота первой звезды (верхний уровень)
        0,      // Высота второй звезды (средний уровень)
        -200    // Высота третьей звезды (нижний уровень)
    ]
    
    // Смещения по X для каждой ступеньки
    static let levelX: [CGFloat] = [
        -100,   // Смещение для первого уровня
         0,     // Смещение для второго уровня
         100    // Смещение для третьего уровня
    ]
    
    // MARK: - Параметры движения
    
    static let riseDistance: CGFloat = 10       // Расстояние подъема за одно обновление
    static let riseSpeed: CGFloat = 50          // Скорость подъема при звуке
    static let fallSpeed: CGFloat = 5           // Скорость падения при тишине
    static let amplitudeThreshold: Float = 10   // Порог громкости для подъема
    
    // MARK: - Параметры звука
    
    static let soundCheckInterval: TimeInterval = 0.1  // Интервал проверки звука (100 мс)
    static let sampleRate: Int = 44100                 // Биттрейд аудио
    
    // MARK: - Параметры интерфейса
    
    static let cornerRadius: CGFloat = 16               // Радиус углов у кнопок
}
