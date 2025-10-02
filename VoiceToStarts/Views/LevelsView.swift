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
    let difficulty: Constants.Difficulty
    let cosmoPosition: Constants.CosmoPosition
    let currentLevel: Int // Текущий уровень космонавта

    // Состояния для анимации
    @State private var starPositions: [Int: CGPoint] = [:]
    @State private var initialAnimationCompleted: Bool = false
    @State private var animatingStarIndex: Int? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                drawLevels(geometry)
                drawStars()
                drawAstronaut(geometry)
            }
        }
        .onAppear {
            print("🌟 LevelsView появился. Начальное состояние звёзд:", collectedStars)
            // Отключаем начальную анимацию через 1 секунду
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                initialAnimationCompleted = true
            }
        }
        .onChange(of: collectedStars) { newStars in
            print("🔄 Изменение состояния collectedStars:", newStars)
            if let newStarIndex = newStars.enumerated().first(where: { $0.element && !collectedStars[$0.offset] })?.offset {
                print("⭐️ Запуск анимации сбора для звезды \(newStarIndex)")
                animatingStarIndex = newStarIndex
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    print("🏁 Завершение анимации сбора для звезды \(newStarIndex)")
                    animatingStarIndex = nil
                }
            }
        }
    }

    private func drawLevels(_ geometry: GeometryProxy) -> some View {
        let stairWidth = geometry.size.width * Constants.Level.width

        return ZStack {
            ForEach(0..<difficulty.levelHeights.count) { index in
                let levelHeight = difficulty.levelHeights[index]
                // Используем пропорциональную высоту для всех столбиков
                let height = geometry.size.height * levelHeight * Constants.Level.maxHeight
                let currentX = geometry.size.width - stairWidth * 2.5 + (CGFloat(index) * stairWidth)

                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: getGradientColors(for: index),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(
                        width: stairWidth,
                        height: height
                    )
                    .position(
                        x: currentX,
                        y: geometry.size.height - height / 2
                    )
                    .onChange(of: geometry.size) { _ in
                        // Обновляем позиции звезд
                        starPositions[index] = CGPoint(
                            x: currentX,
                            y: geometry.size.height - height + (CGFloat(index) * stairWidth / 3)
                        )
                    }
            }
        }
    }

    private func drawStars() -> some View {
        return ZStack {
            ForEach(Array(starPositions.keys.sorted()), id: \.self) { index in
                if let position = starPositions[index] {
                    Group {
                        if !initialAnimationCompleted {
                            // Начальная анимация появления для всех звёзд
                            AnimationView(name: Constants.Anim.star)
                                .setLoopMode(.playOnce)
                                .setContentMode(.scaleAspectFill)
                                .frame(width: 100, height: 100)
                                .position(position)
                                .onAppear {
                                    print("🎬 Звезда \(index): Начальная анимация появления")
                                }
                        } else if !collectedStars[index] || animatingStarIndex == index {
                            // Показываем либо статичную звезду, либо анимацию фейерверка
                            ZStack {
                                // Статичная звезда
                                if !collectedStars[index] {
                                    Image("Star")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .position(position)
                                        .onAppear {
                                            print("⭐️ Звезда \(index): Показ статичной звезды")
                                        }
                                }
                                
                                // Анимация фейерверка при сборе
                                if animatingStarIndex == index {
                                    AnimationView(name: Constants.Anim.fireworks)
                                        .setLoopMode(.playOnce)
                                        .setContentMode(.scaleAspectFill)
                                        .frame(width: 100, height: 100)
                                        .position(position)
                                        .onAppear {
                                            print("🎆 Звезда \(index): Анимация фейерверка")
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func drawAstronaut(_ geometry: GeometryProxy) -> some View {
        // Новая система координат: (0,0) в левом нижнем углу
        // X увеличивается вправо, Y увеличивается вверх
        
        // Вычисляем позицию первого столбца для правильного позиционирования
        let stairWidth = geometry.size.width * Constants.Level.width
        
        // Позиция космонавта на соответствующем столбце
        let columnX = stairWidth + (CGFloat(currentLevel) * stairWidth)
        let astronautX = columnX - stairWidth / 2
        let astronautY = geometry.size.height - Constants.Cosmo.height * 0.3 - cosmoPosition.y
        
        return AnimationView(name: Constants.Anim.austronaut)
            .setLoopMode(.loop)
            .setContentMode(.scaleAspectFill)
            .frame(width: Constants.Cosmo.width, height: Constants.Cosmo.height)
            .position(
                x: astronautX,
                y: astronautY
            )
    }

    private func getGradientColors(for index: Int) -> [Color] {
        switch index {
        case 0:
            return [Color(hex: "4B7BF5"), Color(hex: "A682FF")]  // Первый столбец синий-фиолетовый
        case 1:
            return [Color(hex: "6C7689"), Color(hex: "9BA5C9")]  // Второй столбец серо-голубой
        case 2:
            return [Color(hex: "D9D9D9"), Color(hex: "FFFFFF")]  // Третий столбец светло-серый
        default:
            return [.blue, .purple]
        }
    }
}

// MARK: - Preview
    #Preview {
        LevelsView(
            collectedStars: [false, true, false],
            onStarCollected: { _ in },
            difficulty: .easy,
            cosmoPosition: Constants.CosmoPosition.zero,
            currentLevel: 0
        )
        .frame(width: 400, height: 600)
        .background(Color.black)
    }
