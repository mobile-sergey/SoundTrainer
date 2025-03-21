import SwiftUI
import Lottie

struct BalloonAnimation: View {
    let state: BalloonState
    let viewModel: GameViewModel
    
    @State private var animatedY: CGFloat = 0
    @State private var lastLevelCheck: Int = 0
    
    var body: some View {
        CommonLottieView(name: "astronaut_animation")
            .setLoopMode(.playOnce)
            .setContentMode(.scaleAspectFill)
            .setSpeed(1.0)
            .setPlaying(true)
            .frame(width: 180, height: 180)
            .offset(x: state.xOffset, y: animatedY)
            .onChange(of: state.balloonPosition) { newPosition in
                withAnimation(.linear(duration: calculateDuration())) {
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
        let distance = BalloonConstants.riseDistance
        let speed = state.isSpeaking ? BalloonConstants.riseSpeed : BalloonConstants.fallSpeed
        return Double(distance) / Double(speed)
    }
    
    private func checkLevelProgress(newY: CGFloat) {
        guard state.currentLevel < BalloonConstants.lottieHeights.count,
              lastLevelCheck != state.currentLevel,
              newY <= BalloonConstants.lottieHeights[state.currentLevel] else {
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
