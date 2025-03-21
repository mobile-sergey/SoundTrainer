import SwiftUI
import Lottie

struct BalloonAnimation: View {
    let state: BalloonState
    let viewModel: GameViewModel
    
    @State private var animatedY: CGFloat = 0
    
    var body: some View {
        LottieView(name: "astronaut_animation")
            .frame(width: 180, height: 180)
            .offset(x: state.xOffset, y: animatedY)
            .onChange(of: state.balloonPosition) { newPosition in
                withAnimation(.linear(duration: calculateDuration())) {
                    animatedY = newPosition
                }
            }
            .onChange(of: animatedY) { newY in
                if state.currentLevel < BalloonConstants.lottieHeights.count &&
                    newY <= BalloonConstants.lottieHeights[state.currentLevel] {
                    viewModel.processIntent(.levelReached(level: state.currentLevel))
                }
            }
    }
    
    private func calculateDuration() -> Double {
        let distance = BalloonConstants.riseDistance
        let speed = state.isSpeaking ? BalloonConstants.riseSpeed : BalloonConstants.fallSpeed
        return Double(distance) / Double(speed)
    }
} 
