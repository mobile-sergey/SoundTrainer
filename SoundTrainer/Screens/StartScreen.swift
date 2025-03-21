import SwiftUI
import Lottie
import AVFoundation

struct StartScreen: View {
    @State private var isGameScreenPresented = false
    @State private var showPermissionDialog = false
    
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
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Text("Шарик-Голосовичок")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 100, height: 100)
                    
                    LottieView(name: "rocket_animation")
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                }
                .frame(width: 100, height: 100)
                
                Button(action: {
                    checkMicrophonePermission()
                }) {
                    Text("Начать игру")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Text("Говорите в микрофон, чтобы поднять шарик!")
                    .font(.body)
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding()
            .navigationBarHidden(true)
            .background(
                Group {
                    if #available(iOS 16, *) {
                        NavigationLink(
                            destination: GameScreen(),
                            isActive: $isGameScreenPresented,
                            label: { EmptyView() }
                        )
                    } else {
                        NavigationLink(
                            "",
                            destination: GameScreen(),
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
                Text("Для игры необходимо разрешение на использование микрофона")
            }
        }
    }
    
    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            isGameScreenPresented = true
        case .denied:
            showPermissionDialog = true
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    if granted {
                        isGameScreenPresented = true
                    } else {
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

// Вспомогательное view для отображения Lottie анимации
struct LottieView: UIViewRepresentable {
    let name: String
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: name)
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundBehavior = .forceFinish
        animationView.play()
        
        // Настраиваем корректное масштабирование
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return animationView
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        if !uiView.isAnimationPlaying {
            uiView.play()
        }
    }
}

#Preview {
    StartScreen()
}
