import SwiftUI
import Lottie

struct BalloonAnimation: View {
    let state: BalloonState
    let viewModel: GameViewModel
    
    @State private var animatedY: CGFloat = 0
    @State private var lastLevelCheck: Int = 0
    
    var body: some View {
        ZStack {
            // Основная анимация космонавта
            CommonLottieView(name: "astronaut_animation")
                .setLoopMode(.loop)
                .setContentMode(.scaleAspectFill)
                .frame(width: 180, height: 180)
                .offset(x: state.xOffset, y: animatedY)
            
            // Анимация сбора звезды
            if state.shouldPlayStarAnimation && state.currentLevel < 3 {
                CommonLottieView(name: "star_animation_before_eating")
                    .setLoopMode(.playOnce)
                    .setContentMode(.scaleAspectFill)
                    .frame(width: 100, height: 100)
                    .offset(x: state.xOffset, y: Constants.lottieHeights[state.currentLevel])
            }
            
            // Анимация фейерверка
            if state.shouldShowFireworks {
                CommonLottieView(name: "firework_animation")
                    .setLoopMode(.playOnce)
                    .setContentMode(.scaleAspectFill)
                    .frame(width: 300, height: 300)
            }
        }
        .onChange(of: state.balloonPosition) { newPosition in
            withAnimation(.linear(duration: 0.1)) {
                animatedY = newPosition
            }
        }
        .onChange(of: animatedY) { newY in
            checkLevelProgress(newY: newY)
        }
        .onAppear {
            animatedY = state.balloonPosition
        }
    }
    
    private func calculateDuration() -> Double {
        let distance = Constants.riseDistance
        let speed = state.isSpeaking ? Constants.riseSpeed : Constants.fallSpeed
        return Double(distance) / Double(speed)
    }
    
    private func checkLevelProgress(newY: CGFloat) {
        guard state.currentLevel < Constants.lottieHeights.count,
              lastLevelCheck != state.currentLevel,
              newY <= Constants.lottieHeights[state.currentLevel] else {
            return
        }
        
        lastLevelCheck = state.currentLevel
        
        Task { @MainActor in
            viewModel.processIntent(.levelReached(level: state.currentLevel))
        }
    }
}

#Preview {
    BalloonAnimation(state: .Initial, viewModel: GameViewModel())
} 
