import SwiftUI

struct GameScreen: View {
    @StateObject private var viewModel: GameViewModel
    let onExit: () -> Void
    @State private var showMicrophoneAlert = false
    
    init(onExit: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: GameViewModel())
        self.onExit = onExit
    }
    
    var body: some View {
        ZStack {
            StarryBackground()
            
            StepsPanelAnother(
                collectedStars: viewModel.state.collectedStars,
                onStarCollected: { level in
                    Task { @MainActor in
                        viewModel.collectStar(level: level)
                    }
                }
            )
            .padding([.trailing, .bottom], 16)
            
            BalloonAnimation(state: viewModel.state, viewModel: viewModel)
                .animation(.default, value: viewModel.state)
                .transaction { transaction in
                    transaction.animation = .default
                }
            
            Button(action: {
                onExit()
                Task.detached(priority: .userInitiated) {
                    await MainActor.run {
                        viewModel.cleanup()
                    }
                }
            }) {
                Image(systemName: "arrow.backward")
                    .foregroundColor(.black)
                    .padding(16)
            }
            .position(x: 40, y: 40)
        }
        .onAppear {
            // Запрашиваем разрешение перед началом записи
            SpeechDetector.requestMicrophonePermission { granted in
                if granted {
                    Task { @MainActor in
                        viewModel.startDetecting()
                    }
                } else {
                    showMicrophoneAlert = true
                }
            }
        }
        .alert("Требуется доступ к микрофону", isPresented: $showMicrophoneAlert) {
            Button("Открыть настройки") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Отмена", role: .cancel) {
                // Возвращаемся на предыдущий экран, так как без микрофона игра не работает
                onExit()
            }
        } message: {
            Text("Для работы приложения необходим доступ к микрофону. Пожалуйста, предоставьте разрешение в настройках.")
        }
        .onDisappear {
            Task { @MainActor in
                viewModel.cleanup()
            }
        }
    }
}

#Preview {
    GameScreen(onExit: {})
} 
