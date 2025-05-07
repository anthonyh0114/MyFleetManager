import SwiftUI

struct HeaderView: View {
    var body: some View {
        ZStack {
            // Background Image
            Image("MFM_header")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()
                .overlay(
                    // Dark overlay for better text visibility
                    Color.black.opacity(0.3)
                )
                .background(Color.gray) // Debug background to see the frame
            
            // Title Text
            VStack {
                Text("My Fleet Manager")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 2)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            // Debug print to verify the view is loading
            print("HeaderView appeared")
        }
    }
}

#Preview {
    HeaderView()
} 