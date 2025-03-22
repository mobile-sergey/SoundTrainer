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
            
            LevelsView(
                collectedStars: viewModel.state.collectedStars,
                onStarCollected: { level in
                    Task { @MainActor in
                        viewModel.collectStar(level: level)
                    }
                }
            )
            .padding([.trailing, .bottom], 16)
            
            // Основная анимация космонавта
            AnimationView(name: "astronaut_animation")
                .setLoopMode(.loop)
                .setContentMode(.scaleAspectFill)
                .frame(width: 180, height: 180)
                .offset(x: state.xOffset, y: animatedY)
            
            // Анимация сбора звезды
            if state.shouldPlayStarAnimation && state.currentLevel < 3 {
                AnimationView(name: "star_animation_before")
                    .setLoopMode(.playOnce)
                    .setContentMode(.scaleAspectFill)
                    .frame(width: 100, height: 100)
                    .offset(x: state.xOffset, y: Constants.levelY[state.currentLevel])
            }
            
            // Анимация фейерверка
            if state.shouldShowFireworks {
                AnimationView(name: "star_animation_after")
                    .setLoopMode(.playOnce)
                    .setContentMode(.scaleAspectFill)
                    .frame(width: 300, height: 300)
            }
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
        let distance = Constants.riseDistance
        let speed = state.isSpeaking ? Constants.riseSpeed : Constants.fallSpeed
        return Double(distance) / Double(speed)
    }
    
    private func checkLevelProgress(newY: CGFloat) {
        guard state.currentLevel < Constants.levelY.count,
              lastLevelCheck != state.currentLevel,
              newY <= Constants.levelY[state.currentLevel] else {
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
