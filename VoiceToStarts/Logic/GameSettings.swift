//
//  GameSettings.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import Foundation

class GameSettings: ObservableObject {
    @Published var difficulty: Constants.Difficulty = .easy
    
    private let userDefaults = UserDefaults.standard
    private let difficultyKey = "game_difficulty"
    
    init() {
        loadDifficulty()
    }
    
    func setDifficulty(_ newDifficulty: Constants.Difficulty) {
        difficulty = newDifficulty
        saveDifficulty()
    }
    
    private func loadDifficulty() {
        if let savedDifficulty = userDefaults.string(forKey: difficultyKey),
           let difficulty = Constants.Difficulty(rawValue: savedDifficulty) {
            self.difficulty = difficulty
        }
    }
    
    private func saveDifficulty() {
        userDefaults.set(difficulty.rawValue, forKey: difficultyKey)
    }
}
