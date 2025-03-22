//
//  GameAnimationView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI
import Lottie

struct GameView: View {
    let state: GameState
    let viewModel: GameViewModel
    
    @State private var animatedY: CGFloat = 0
    @State private var lastLevelCheck: Int = 0
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            // Уровни и звёзды
            LevelsView(
                collectedStars: viewModel.state.collectedStars,
                onStarCollected: { level in
                    Task { @MainActor in
                        viewModel.collectStar(level: level)
                    }
                }
            )
            
            // Основная анимация космонавта
            AnimationView(name: Constants.Anim.austronaut)
                .setLoopMode(.loop)
                .setContentMode(.scaleAspectFill)
                .frame(width: 180, height: 180)
                .offset(x: state.xOffset, y: animatedY)
        }
        .onChange(of: state.position) { newPosition in
            withAnimation(.linear(duration: 0.1)) {
                animatedY = newPosition
            }
        }
        .onChange(of: animatedY) { newY in
            checkLevelProgress(newY: newY)
        }
        .onAppear {
            animatedY = state.position
        }
    }
    
    private func calculateDuration() -> Double {
        let distance = Constants.Move.riseDistance
        let speed = state.isSpeaking ? Constants.Move.riseSpeed : Constants.Move.fallSpeed
        return Double(distance) / Double(speed)
    }
    
    private func checkLevelProgress(newY: CGFloat) {
        guard state.currentLevel < Constants.Level.y.count,
              lastLevelCheck != state.currentLevel,
              newY <= Constants.Level.y[state.currentLevel] else {
            return
        }
        
        lastLevelCheck = state.currentLevel
        
        Task { @MainActor in
            viewModel.processIntent(.levelReached(level: state.currentLevel))
        }
    }
}

#Preview {
    GameView(state: .Initial, viewModel: GameViewModel())
}
