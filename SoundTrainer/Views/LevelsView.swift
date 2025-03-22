//
//  ColumsView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI

struct LevelsView: View {
    let collectedStars: [Bool]
    let onStarCollected: (Int) -> Void
    
    // Состояния для анимации
    @State private var starPositions: [Int: CGPoint] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                drawLevels(geometry)
                drawStars()
            }
        }
    }
    
    private func drawLevels(_ geometry: GeometryProxy) -> some View {
        let stairWidth = geometry.size.width * Constants.Level.width
        
        return ZStack {
            ForEach(0..<3) { index in
                let height = geometry.size.height * Constants.Level.heights[index]
                let currentX = geometry.size.width - stairWidth * 2.5 + (CGFloat(index) * stairWidth)
                
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: getGradientColors(for: index),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: stairWidth, height: height * Constants.Level.maxHeight)
                    .position(x: currentX, y: geometry.size.height - (height * Constants.Level.maxHeight) / 2)
                    .onChange(of: geometry.size) { _ in
                        // Обновляем позиции звезд
                        starPositions[index] = CGPoint(
                            x: currentX,
                            y: geometry.size.height - (height * Constants.Level.maxHeight) + (CGFloat(index) * stairWidth / 3)
                        )
                    }
            }
        }
    }
    
    private func drawStars() -> some View {
        
        return ZStack {
            ForEach(Array(starPositions.keys.sorted()), id: \.self) { index in
                if let position = starPositions[index] {
                    StarView(
                        position: position,
                        isCollected: false,
                            // collectedStars.indices.contains(index) ? collectedStars[index] : false,
                        onCollect: { onStarCollected(index) }
                    )
                }
            }
        }
    }
    
    private func getGradientColors(for index: Int) -> [Color] {
        switch index {
        case 0:
            return [Color(hex: "4B7BF5"), Color(hex: "A682FF")] // Первый столбец синий-фиолетовый
        case 1:
            return [Color(hex: "6C7689"), Color(hex: "9BA5C9")] // Второй столбец серо-голубой
        case 2:
            return [Color(hex: "D9D9D9"), Color(hex: "FFFFFF")] // Третий столбец светло-серый
        default:
            return [.blue, .purple]
        }
    }
}

// Вспомогательное расширение для создания цвета из HEX
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


#Preview {
    LevelsView(
        collectedStars: [false, true, false],
        onStarCollected: { _ in }
    )
    .frame(width: 400, height: 600)
    .background(Color.black)
}
