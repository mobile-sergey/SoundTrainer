//
//  StartScreen.swift
//  SoundTrainer
//
//  Created by Sergey on 21.03.2025.
//

import AVFoundation
import Lottie
import SwiftUI
import os.log

struct StartScreen: View {
    @State private var isGameScreenPresented = false
    @State private var showPermissionDialog = false
    @State private var isRocketAnimationComplete = false

    var body: some View {
        if #available(iOS 16, *) {
            NavigationStack {
                mainContent
            }
        } else {
            NavigationView {
                mainContent
            }
        }
    }

    private var mainContent: some View {
        ZStack {
            StarsFallingBackgroundView()  // Фон со звёздами

            VStack(spacing: 24) {
                Text("Voice to stars")
                    .foregroundColor(.active)
                    .font(.title)
                    .fontWeight(.bold)

                // Анимация ракеты (1 раз)
                let rocketAnimation = AnimationView(name: Constants.Anim.rocket)
                    .setLoopMode(.playOnce)
                    .setContentMode(.scaleAspectFill)
                    .setSpeed(1.5)
                    .setPlaying(!isRocketAnimationComplete)

                // Анимация космонавта (бесконечно)
                let astronautAnimation = AnimationView(
                    name: Constants.Anim.austronaut
                )
                .setLoopMode(.loop)
                .setContentMode(.scaleAspectFill)
                .setSpeed(1.0)
                .setPlaying(isRocketAnimationComplete)

                // Отслеживаем завершение анимации ракеты
                if !isRocketAnimationComplete {
                    rocketAnimation
                        .onAnimationComplete {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isRocketAnimationComplete = true
                            }
                        }
                        .frame(width: 250, height: 250)
                        .clipShape(Circle())
                } else {
                    astronautAnimation
                        .frame(width: 250, height: 250)
                        .transition(.opacity.animation(.easeIn(duration: 0.5)))
                }

                Button(action: {
                    os_log("Start button clicked", log: .default, type: .debug)
                    checkMicrophonePermission()
                }) {
                    Text("Начать игру")
                        .font(.title2)
                        .frame(width: 200, height: 50)
                        .background(.active)
                        .cornerRadius(50)
                }

                Text("Говорите в микрофон, чтобы поднять шарик!")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding()
            .navigationBarHidden(true)
            .background(
                Group {
                    if #available(iOS 16, *) {
                        NavigationLink(
                            destination: GameScreen(onExit: {
                                isRocketAnimationComplete = false  // Сбрасываем состояние анимации при выходе
                            }),
                            isActive: $isGameScreenPresented,
                            label: { EmptyView() }
                        )
                    } else {
                        NavigationLink(
                            "",
                            destination: GameScreen(onExit: {
                                isRocketAnimationComplete = false  // Сбрасываем состояние анимации при выходе
                            }),
                            isActive: $isGameScreenPresented
                        )
                    }
                }
            )
            .alert("Требуется доступ", isPresented: $showPermissionDialog) {
                Button("Дать разрешение") {
                    openSettings()
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text(
                    "Для игры необходимо разрешение на использование микрофона")
            }
        }
    }

    private func checkMicrophonePermission() {
        os_log("Checking microphone permission", log: .default, type: .debug)
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            os_log("Permission already granted", log: .default, type: .debug)
            isGameScreenPresented = true
        case .denied:
            os_log("Permission denied", log: .default, type: .debug)
            showPermissionDialog = true
        case .undetermined:
            os_log("Requesting permission", log: .default, type: .debug)
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        os_log(
                            "Permission granted", log: .default, type: .debug)
                        isGameScreenPresented = true
                    } else {
                        os_log(
                            "Permission denied after request", log: .default,
                            type: .debug)
                        showPermissionDialog = true
                    }
                }
            }
        @unknown default:
            break
        }
    }

    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    StartScreen()
}
