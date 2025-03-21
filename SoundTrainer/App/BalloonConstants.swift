import SwiftUI

enum BalloonConstants {
    // MARK: - Animation Parameters
    static let baseY: CGFloat = 2270
    static let initialLottieY: CGFloat = 750
    static let riseDistance: CGFloat = 600
    static let riseSpeed: CGFloat = 500    // points per second (подъем)
    static let fallSpeed: CGFloat = 400    // points per second (падение)
    static let balloonRadius: CGFloat = 90
    static let balloonYCorrection: CGFloat = 150
    
    // Смещение для Lottie
    static let lottieOffset: CGFloat = 2270 - 750 // 1520 (разница между старой и новой Y-координатой)
    
    // MARK: - Gameplay Configuration
    static let levelHeights: [CGFloat] = [1800, 1200, 600]
    
    // Высоты для проверки достижения уровней Lottie-анимацией
    static let lottieHeights: [CGFloat] = [540, 280, 60]
    
    static let stairOffsets: [CGFloat] = [330, 540, 750]
    
    static let lottieStairOffsets: [CGFloat] = [90, 180, 270]
    
    static let stairWidthRatio: CGFloat = 1/5
    
    // MARK: - Visual Design
    static let balloonColor = Color.green
    
    static let stairColors: [Color] = [
        Color(.sRGB, red: 96/255, green: 125/255, blue: 139/255, opacity: 1),  // Светло-серый
        Color(.sRGB, red: 69/255, green: 90/255, blue: 100/255, opacity: 1),   // Средне-серый
        Color(.sRGB, red: 55/255, green: 71/255, blue: 79/255, opacity: 1)     // Темно-серый
    ]
    
    static let stairPaddingRatio: CGFloat = 0.2
    static let cornerRadius: CGFloat = 16
    
    // MARK: - Mountain Gradients
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
    
    // MARK: - Physics
    static let amplitudeThreshold: Float = 500
    static let soundCheckInterval: TimeInterval = 0.1  // 100ms
    static let sampleRate: Int = 44100
} 