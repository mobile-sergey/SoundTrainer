import SwiftUI

struct StartScreen: View {
    @State private var isGameScreenPresented = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sound Trainer")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Тренируйте свой слух")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button(action: {
                isGameScreenPresented = true
            }) {
                Text("Начать игру")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 30)
        }
        .padding()
        .navigationDestination(isPresented: $isGameScreenPresented) {
            GameScreen()
        }
    }
}

#Preview {
    NavigationStack {
        StartScreen()
    }
} 