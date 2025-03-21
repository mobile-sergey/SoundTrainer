import SwiftUI

struct GameScreen: View {
    @StateObject private var viewModel: GameViewModel
    let onExit: () -> Void
    
    init(onExit: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel())
        self.onExit = onExit
    }
    
    var body: some View {
        ZStack {
            StarryBackground()
            
            StepsPanelAnother(
                collectedStars: viewModel.state.collectedStars,
                onStarCollected: { level in
                    viewModel.collectStar(level: level)
                }
            )
            .padding([.trailing, .bottom], 16)
            
            BalloonAnimation(state: viewModel.state, viewModel: viewModel)
            
            Button(action: onExit) {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.black)
                    .padding(16)
            }
            .position(x: 40, y: 40)
        }
        .onAppear {
            viewModel.startDetecting()
        }
        .onDisappear {
            viewModel.stopDetecting()
        }
    }
}

#Preview {
    GameScreen(onExit: {})
} 
