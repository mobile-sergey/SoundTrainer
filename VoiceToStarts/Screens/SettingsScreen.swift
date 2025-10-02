//
//  SettingsScreen.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import SwiftUI

struct SettingsScreen: View {
    @StateObject private var gameSettings = GameSettings()
    @State private var selectedDifficulty: Constants.Difficulty = .easy
    let onBack: () -> Void
    
    var body: some View {
        ZStack {
            StarsFallingBackgroundView()
            
            VStack(spacing: 32) {
                // Заголовок с кнопкой назад
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(Color("ActiveColor"))
                    }
                    
                    Text("Настройки")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ActiveColor"))
                        .padding(.leading, 16)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                // Настройки сложности
                VStack(alignment: .leading, spacing: 16) {
                    Text("Уровень сложности")
                        .font(.headline)
                        .foregroundColor(Color("ActiveColor"))
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        ForEach(Constants.Difficulty.allCases, id: \.self) { difficulty in
                            DifficultyOption(
                                difficulty: difficulty,
                                isSelected: selectedDifficulty == difficulty,
                                onSelected: {
                                    selectedDifficulty = difficulty
                                    gameSettings.setDifficulty(difficulty)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            selectedDifficulty = gameSettings.difficulty
        }
    }
}

struct DifficultyOption: View {
    let difficulty: Constants.Difficulty
    let isSelected: Bool
    let onSelected: () -> Void
    
    var body: some View {
        Button(action: onSelected) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? Color("ActiveColor") : Color.gray)
                    .font(.title2)
                
                Text(difficulty.rawValue)
                    .font(.body)
                    .foregroundColor(Color("ActiveColor"))
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color("ActiveColor") : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsScreen(onBack: {})
}
