//
//  GameBackgroundView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI

struct BackgroundView: View {
    // Кэш для хранения сгенерированных звезд
    private static var starsCache: [Int: [Star]] = [:]
    
    private let stars: [Star]
    
    init(starCount: Int = 200) {
        // Используем кэшированные звезды если они есть, иначе генерируем новые
        if let cachedStars = Self.starsCache[starCount] {
            self.stars = cachedStars
        } else {
            let newStars = Self.generateStars(count: starCount)
            Self.starsCache[starCount] = newStars
            self.stars = newStars
        }
    }
    
    var body: some View {
        Canvas { context, size in
            // Рисуем градиентное небо
            let gradient = Gradient(colors: [
                Color(red: 0/255, green: 4/255, blue: 40/255),  // Темно-синий
                Color(red: 0/255, green: 78/255, blue: 146/255) // Синий
            ])
            
            let backgroundRect = Path(CGRect(origin: .zero, size: size))
            context.fill(
                backgroundRect,
                with: .linearGradient(
                    gradient,
                    startPoint: .zero,
                    endPoint: CGPoint(x: 0, y: size.height)
                )
            )
            
            // Рисуем звезды
            for star in stars {
                context.opacity = star.alpha
                context.fill(
                    Path(
                        ellipseIn: CGRect(
                            x: star.position.x * size.width,
                            y: star.position.y * size.height,
                            width: star.radius * 2,
                            height: star.radius * 2
                        )
                    ),
                    with: .color(star.color)
                )
            }
        }
        .ignoresSafeArea()
    }
    
    private static func generateStars(count: Int) -> [Star] {
        (0..<count).map { _ in
            Star(
                position: CGPoint(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1)
                ),
                radius: CGFloat.random(in: 1...2),
                color: [
                    Color(red: 255/255, green: 253/255, blue: 208/255), // Кремовый
                    Color(red: 240/255, green: 255/255, blue: 255/255), // Голубой
                    Color.white
                ].randomElement()!,
                alpha: CGFloat.random(in: 0.3...0.8)
            )
        }
    }
}

struct Star {
    let position: CGPoint
    let radius: CGFloat
    let color: Color
    let alpha: CGFloat
}

// Предварительный просмотр
#Preview {
    BackgroundView(starCount: 200)
}

// Вспомогательное расширение для анимации звезд (опционально)
extension BackgroundView {
    func withAnimation() -> some View {
        self.modifier(StarTwinkleModifier())
    }
}

// Модификатор для мерцания звезд (опционально)
struct StarTwinkleModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
} 
