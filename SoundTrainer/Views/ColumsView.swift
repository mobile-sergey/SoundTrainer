//
//  ColumsView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI

struct ColumsView: View {
    let collectedStars: [Bool]
    let onStarCollected: (Int) -> Void
    
    @State private var progress: CGFloat = 0
    @State private var starPositions: [Int: CGPoint] = [:]
    @State private var showFirework: Bool = false
    @State private var fireworkPosition: CGPoint = .zero
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                starsAndColumns(geometry)
                firework
            }
        }
    }
    
    // Выделяем столбцы со звездами в отдельное представление
    private func starsAndColumns(_ geometry: GeometryProxy) -> some View {
        HStack(alignment: .bottom, spacing: 15) {
            Spacer(minLength: geometry.size.width * 0.3) // Уменьшаем пространство слева
            ForEach(0..<3) { index in
                columnWithStar(index: index, geometry: geometry)
            }
        }
        .padding(.trailing, 30) // Небольшой отступ справа
        .padding(.bottom, 30)
    }
    
    // Отдельное представление для столбца со звездой
    private func columnWithStar(index: Int, geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            starView(index: index, geometry: geometry)
            columnView(index: index, geometry: geometry)
        }
    }
    
    // Звезда
    private func starView(index: Int, geometry: GeometryProxy) -> some View {
        Image(systemName: "star.fill")
            .foregroundColor(.yellow)
            .font(.system(size: 40))
            .padding(.bottom, 10)
            .onTapGesture {
                let xPosition = geometry.size.width - (30 + CGFloat(2-index) * 95) // Обновляем позицию фейерверка
                fireworkPosition = CGPoint(x: xPosition, y: 50)
                showFirework = true
                onStarCollected(index)
            }
    }
    
    // Столбец
    private func columnView(index: Int, geometry: GeometryProxy) -> some View {
        let availableHeight = geometry.size.height * 0.85 // Оставляем 15% сверху для плашки записи
        
        return RoundedRectangle(cornerRadius: 25)
            .fill(
                LinearGradient(
                    colors: getGradientColors(for: index),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(
                width: 80,
                height: getColumnHeight(index: index, totalHeight: availableHeight)
            )
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
    
    private func getColumnHeight(index: Int, totalHeight: CGFloat) -> CGFloat {
        let heights: [CGFloat] = [0.35, 0.7, 1.0] // Пропорции остаются теми же
        return totalHeight * heights[index]
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
    ColumsView(
        collectedStars: [false, false, false],
        onStarCollected: { _ in }
    )
    .frame(width: 400, height: 600)
    .background(Color.black)
}
