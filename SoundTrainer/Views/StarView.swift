//
//  StarView.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI
import Lottie

struct StarView: View {
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
            AnimationView(name: isCollected ? "star_animation_after" : "star_animation_before")
                .setLoopMode(.playOnce)
                .setContentMode(.scaleAspectFill)
                .setSpeed(0.8)
                .setPlaying(isCollected)
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
        StarView(isCollected: false) {
            print("Star collected!")
        }
        
        StarView(isCollected: true) {
            print("Already collected star!")
        }
    }
} 
