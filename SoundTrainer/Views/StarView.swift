//
//  StarItemView.swift
//  SoundTrainer
//
//  Created by Sergey on 22.03.2025.
//

import Lottie
import SwiftUI

// Новый компонент для звезды
struct StarView: View {
    let position: CGPoint
    let isCollected: Bool
    let onCollect: () -> Void

    @State private var isAnimating: Bool = false
    @State private var showStar: Bool = true

    init(position: CGPoint, isCollected: Bool, onCollect: @escaping () -> Void)
    {
        self.position = position
        self.isCollected = isCollected
        self.onCollect = onCollect
        self._isAnimating = State(initialValue: true)
        self._showStar = State(initialValue: !self.isAnimating)
    }

    var body: some View {
        ZStack {
            if isAnimating {
                AnimationView(
                    name: isCollected
                        ? Constants.Anim.fireworks : Constants.Anim.star
                )
                .setLoopMode(.playOnce)
                .setContentMode(.scaleAspectFill)
                .setSpeed(1.0)
                .setPlaying(true)
                .onAnimationComplete {
                    isAnimating = false
                    showStar = !isCollected
                    if (isCollected) {
                        onCollect()
                    }
                }
                .frame(width: 120, height: 120)
                .position(position)
            }

            if showStar {
                Image("Star")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .position(position)
            }
        }
    }

    private func handleStarCollection() {
        showStar = false
        isAnimating = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isAnimating = false
            showStar = true
            onCollect()
        }
    }
}

#Preview {
    StarView(
        position: CGPoint(x: 200.0, y: 150.0),
        isCollected: true,
        onCollect: {}
    )
    .frame(width: 400, height: 300)
    .background(Color.black)

    StarView(
        position: CGPoint(x: 200.0, y: 150.0),
        isCollected: false,
        onCollect: {}
    )
    .frame(width: 400, height: 300)
    .background(Color.black)
}
