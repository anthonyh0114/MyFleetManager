import SwiftUI

struct HeaderBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.8),
                Color.blue.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // Add a subtle pattern
            Image(systemName: "car.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .foregroundColor(.white.opacity(0.1))
                .rotationEffect(.degrees(-15))
        )
    }
}

#Preview {
    HeaderBackgroundView()
        .frame(height: 200)
} 