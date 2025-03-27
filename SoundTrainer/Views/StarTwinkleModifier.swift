//
//  StarTwinkleModifier.swift
//  SoundTrainer
//
//  Created by Sergey on 27.03.2025.
//

import SwiftUI

// Модификатор для мерцания звезд (опционально)
struct StarTwinkleModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Preview
#Preview {
    BackgroundView().modifier(StarTwinkleModifier())
}
