//
//  FireworkEffect.swift
//  SoundTrainer
//
//  Created by Sergey on 22.03.2025.
//


import SwiftUI

// Простой эффект фейерверка
struct FireworksView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 1
    
    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 10, height: 10)
                    .offset(x: 50 * cos(Double(index) * .pi / 4) * scale,
                           y: 50 * sin(Double(index) * .pi / 4) * scale)
            }
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1
                opacity = 0
            }
        }
    }
}
