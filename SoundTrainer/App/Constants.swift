import SwiftUI

enum Constants {
    // MARK: - Animation Parameters

    static let initialLottieY: CGFloat = 250
    static let balloonRadius: CGFloat = 90
    static let balloonYCorrection: CGFloat = 150
    
    // MARK: - Gameplay Configuration
    static let stairOffsets: [CGFloat] = [330, 540, 750]
    
    static let stairWidthRatio: CGFloat = 1/5
    
    static let baseY: CGFloat = 250  // Начальная позиция космонавта (внизу экрана)
    
    // Начальная позиция Y для шарика (внизу экрана)
    static let initialY: CGFloat = UIScreen.main.bounds.height - 100
    
    // Начальная позиция и высоты уровней
    static let lottieHeights: [CGFloat] = [
        200,   // Высота первой звезды (верхний уровень)
        0,   // Высота второй звезды (средний уровень)
        -200    // Высота третьей звезды (нижний уровень)
    ]
    
    // Параметры движения
    static let riseDistance: CGFloat = 10      // Расстояние подъема за одно обновление
    static let fallSpeed: CGFloat = 5          // Скорость падения
    static let amplitudeThreshold: Float = 10 // Порог громкости для подъема
    
    // Смещения по X для каждой ступеньки
    static let lottieStairOffsets: [CGFloat] = [
        -100,  // Смещение для верхнего уровня
        0,     // Смещение для среднего уровня
        100    // Смещение для нижнего уровня
    ]
    
    // Высоты уровней для звезд (те же, что и lottieHeights)
    static let levelHeights: [CGFloat] = lottieHeights
    
    static let soundCheckInterval: TimeInterval = 0.1  // Интервал проверки звука (100 мс)
    static let sampleRate: Int = 44100
    
    static let fallThreshold: Float = 5             // Порог для падения
    static let riseSpeed: CGFloat = 50             // Скорость подъема при звуке
    
    // MARK: - Visual Design
    static let balloonColor = Color.green
    
    static let stairColors: [Color] = [
        Color(.sRGB, red: 96/255, green: 125/255, blue: 139/255, opacity: 1),  // Светло-серый
        Color(.sRGB, red: 69/255, green: 90/255, blue: 100/255, opacity: 1),   // Средне-серый
        Color(.sRGB, red: 55/255, green: 71/255, blue: 79/255, opacity: 1)     // Темно-серый
    ]
    
    static let stairPaddingRatio: CGFloat = 0.2
    static let cornerRadius: CGFloat = 16
    
    static let mountainColors: [[Color]] = [
        [
            Color(.sRGB, red: 142/255, green: 158/255, blue: 171/255, opacity: 1),
            Color(.sRGB, red: 238/255, green: 242/255, blue: 243/255, opacity: 1)
        ],  // Серо-голубой градиент
        [
            Color(.sRGB, red: 99/255, green: 111/255, blue: 164/255, opacity: 1),
            Color(.sRGB, red: 232/255, green: 203/255, blue: 192/255, opacity: 1)
        ],  // Сине-бежевый градиент
        [
            Color(.sRGB, red: 69/255, green: 104/255, blue: 220/255, opacity: 1),
            Color(.sRGB, red: 176/255, green: 106/255, blue: 179/255, opacity: 1)
        ],  // Сине-фиолетовый градиент
        [
            Color(.sRGB, red: 41/255, green: 128/255, blue: 185/255, opacity: 1),
            Color(.sRGB, red: 109/255, green: 213/255, blue: 250/255, opacity: 1)
        ],  // Голубой градиент
        [
            Color(.sRGB, red: 44/255, green: 62/255, blue: 80/255, opacity: 1),
            Color(.sRGB, red: 253/255, green: 116/255, blue: 108/255, opacity: 1)
        ]   // Темно-синий с оранжевым
    ]

}
