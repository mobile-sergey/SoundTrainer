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
    
    // Константы
    private let stairWidthRatio: CGFloat = 0.2 // Аналог STAIR_WIDTH_RATIO
    private let paddingFromAstronaut: CGFloat = 60 // Аналог PADDING_FROM_ASTRONAUT * 2
    private let cornerRadius: CGFloat = 25 // Аналог CORNER_RADIUS
    
    // Состояния для анимации
    @State private var progress: CGFloat = 0.8
    @State private var starPositions: [Int: CGPoint] = [:]
    @State private var showFirework: Bool = false
    @State private var fireworkPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Canvas заменяем на собственное представление для отрисовки колонок
                columnsView(geometry)
                
                // Отрисовка звезд
                ForEach(Array(starPositions.keys.sorted()), id: \.self) { index in
                    if let position = starPositions[index] {
                        StarView(
                            position: position,
                            isCollected: collectedStars.indices.contains(index) ? collectedStars[index] : false,
                            onCollect: { onStarCollected(index) }
                        )
                    }
                }
                
                firework
            }
        }
    }
    
    private func columnsView(_ geometry: GeometryProxy) -> some View {
        let stairWidth = geometry.size.width * stairWidthRatio
        let heights: [CGFloat] = [0.35, 0.7, 1.0] // Аналог LEVEL_HEIGHTS
        
        return ZStack {
            ForEach(0..<3) { index in
                let height = geometry.size.height * heights[index]
                let currentX = geometry.size.width - stairWidth - paddingFromAstronaut - (CGFloat(index) * stairWidth)
                
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: getGradientColors(for: index),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: stairWidth, height: height * progress)
                    .position(x: currentX, y: geometry.size.height - (height * progress) / 2)
                    .onChange(of: geometry.size) { _ in
                        // Обновляем позиции звезд
                        starPositions[index] = CGPoint(
                            x: currentX - stairWidth / 3,
                            y: geometry.size.height - height - 55 // 55 - половина размера звезды
                        )
                    }
            }
        }
    }
    
    // Фейерверк
    private var firework: some View {
        Group {
            if showFirework {
                FireworksView()
                    .frame(width: 100, height: 100)
                    .position(fireworkPosition)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showFirework = false
                        }
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
