import SwiftUI
import Lottie

struct AnimatedStar: View {
    let isCollected: Bool
    let onCollect: () -> Void
    
    @State private var showCollectAnimation: Bool
    
    init(isCollected: Bool, onCollect: @escaping () -> Void) {
        self.isCollected = isCollected
        self.onCollect = onCollect
        self._showCollectAnimation = State(initialValue: isCollected)
    }
    
    var body: some View {
        if !isCollected || showCollectAnimation {
            StarLottieView(name: isCollected ? "star_animation_after_eating_3" : "star_animation_before_eating") { lottieView in
                lottieView.loopMode = .playOnce
                lottieView.animationSpeed = 0.8
            }
            .frame(width: 120, height: 120)
            .background(Color.clear)
            .zIndex(0.5)
            .onTapGesture {
                if !isCollected {
                    onCollect()
                }
            }
            .onChange(of: isCollected) { newValue in
                if newValue {
                    // Ждем завершения анимации
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        showCollectAnimation = false
                        onCollect()
                    }
                }
            }
        }
    }
}


// Предварительный просмотр
#Preview {
    VStack(spacing: 20) {
        AnimatedStar(isCollected: false) {
            print("Star collected!")
        }
        
        AnimatedStar(isCollected: true) {
            print("Already collected star!")
        }
    }
} 
