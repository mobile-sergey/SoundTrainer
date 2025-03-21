//
//  StarItem.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//


import SwiftUI

struct StarItem: View {
    let position: CGPoint
    let isCollected: Bool
    let onCollect: () -> Void
    
    var body: some View {
        ZStack {
            if !isCollected {
                AnimatedStar(
                    isCollected: false,
                    onCollect: onCollect
                )
            } else {
                AnimatedStar(
                    isCollected: true,
                    onCollect: {}
                )
            }
        }
        .frame(width: 120, height: 120)
        .position(x: position.x, y: position.y)
    }
}