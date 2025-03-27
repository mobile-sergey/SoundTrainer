//
//  StarsFallingBackgroundView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import SwiftUI

struct StarsFallingBackgroundView: View {
    @State private var fallingStars: [FallingStar] = (0..<15).map { _ in
        FallingStar(
            x: CGFloat.random(in: 0...100),
            y: -20,
            speed: CGFloat.random(in: 0.3...1.1),
            size: CGFloat.random(in: 1...3),
            alpha: CGFloat.random(in: 0.5...1.0),
            trailLength: CGFloat.random(in: 20...50),
            trailAlpha: CGFloat.random(in: 0.1...0.4)
        )
    }

    let timer = Timer.publish(every: 0.016, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.102, green: 0.106, blue: 0.149),
                    Color(red: 0.176, green: 0.169, blue: 0.333),
                    Color(red: 0.231, green: 0.169, blue: 0.427),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            // Статичные звёзды
            Canvas { context, size in
                let starColors: [Color] = [
                    .white.opacity(0.25),
                    .white.opacity(0.375),
                    .white.opacity(0.5),
                ]

                for _ in 0..<100 {
                    let x = CGFloat.random(in: 0..<size.width)
                    let y = CGFloat.random(in: 0..<size.height)
                    let starSize = CGFloat.random(in: 0.5...2.0)
                    let starColor = starColors.randomElement()!

                    context.stroke(
                        Path(
                            ellipseIn: CGRect(
                                x: x, y: y, width: starSize, height: starSize)),
                        with: .color(starColor)
                    )
                }
            }

            // Падающие звёзды
            Canvas { context, size in
                for star in fallingStars {
                    let x = star.x * size.width / 100
                    let y = star.y * size.height / 100

                    // Сама звезда
                    context.fill(
                        Path(
                            ellipseIn: CGRect(
                                x: x - star.size / 2,
                                y: y - star.size / 2,
                                width: star.size,
                                height: star.size
                            )),
                        with: .color(.white.opacity(star.alpha))
                    )

                    // Трек звезды (изменено на верхнюю часть)
                    let trail = Path { path in
                        path.move(to: CGPoint(x: x, y: y - star.trailLength))  // Начало шлейфа выше звезды
                        path.addLine(to: CGPoint(x: x, y: y))  // Конец шлейфа на уровне звезды
                    }
                    context.stroke(
                        trail,
                        with: .color(.white.opacity(star.trailAlpha)),
                        lineWidth: star.size * 0.5
                    )
                }
            }
        }
        .onReceive(timer) { _ in
            updateFallingStars()
        }
    }

    private func updateFallingStars() {
        for i in fallingStars.indices {
            fallingStars[i].y += fallingStars[i].speed

            if fallingStars[i].y > 100 {
                fallingStars[i] = FallingStar(
                    x: CGFloat.random(in: 0...100),
                    y: -20,
                    speed: CGFloat.random(in: 0.3...1.1),
                    size: CGFloat.random(in: 1...3),
                    alpha: CGFloat.random(in: 0.5...1.0),
                    trailLength: CGFloat.random(in: 20...50),
                    trailAlpha: CGFloat.random(in: 0.1...0.4)
                )
            }
        }
    }
}

// MARK: - Preview
#Preview {
    StarsFallingBackgroundView()
}
