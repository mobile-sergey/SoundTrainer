import SwiftUI

struct GameScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Игровой экран")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Здесь будет игра")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    GameScreen()
} 