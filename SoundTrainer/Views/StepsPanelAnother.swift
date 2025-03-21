import SwiftUI

struct StepsPanelAnother: View {
    let collectedStars: [Bool]
    let onStarCollected: (Int) -> Void
    
    @State private var progress: CGFloat = 0
    @State private var starPositions: [Int: CGPoint] = [:]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Canvas {
                    context,
                    size in
                    let stairWidth = size.width * BalloonConstants.stairWidthRatio
                    let paddingFromBalloon = BalloonConstants.balloonRadius * 2
                    let starRadius: CGFloat = 110
                    
                    var currentX = size.width - stairWidth - paddingFromBalloon
                    
                    // Рисуем ступеньки
                    for (index, height) in BalloonConstants.levelHeights
                        .enumerated() {
                        let colors = BalloonConstants.mountainColors[index % BalloonConstants.mountainColors.count]
                        
                        // Создаем градиент для ступеньки
                        let gradient = Gradient(colors: colors)
                        let gradientRect = CGRect(
                            x: currentX + paddingFromBalloon,
                            y: size.height - height * progress,
                            width: stairWidth,
                            height: height
                        )
                        
                        // Рисуем ступеньку с закругленными углами и градиентом
                        context.fill(
                            Path(
                                roundedRect: gradientRect,
                                cornerRadius: BalloonConstants.cornerRadius
                            ),
                            with: .linearGradient(
                                gradient,
                                startPoint: CGPoint(
                                    x: 0,
                                    y: size.height - height * progress
                                ),
                                endPoint: CGPoint(x: 0, y: size.height)
                            )
                        )
                        
                        // Сохраняем позицию для звезды
                        starPositions[index] = CGPoint(
                            x: currentX + paddingFromBalloon - stairWidth / 3,
                            y: size.height - height - starRadius
                        )
                        currentX -= stairWidth
                    }
                }
                
                // Размещаем звезды
                ForEach(
                    Array(BalloonConstants.levelHeights.enumerated()),
                    id: \.offset
                ) {
                    index,
                    _ in
                    if let position = starPositions[index] {
                        StarItem(
                            position: position,
                            isCollected: collectedStars.indices
                                .contains(index) ? collectedStars[index] : false,
                            onCollect: { onStarCollected(index)
                            }
                        )
                    }
                }
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 2).repeatForever(autoreverses: false)
            ) {
                progress = 1
            }
        }
    }
}
