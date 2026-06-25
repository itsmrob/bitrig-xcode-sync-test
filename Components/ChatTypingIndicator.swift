import SwiftUI

struct ChatTypingIndicator: View {
  @State private var isAnimating = false

  var body: some View {
    HStack(spacing: 6) {
      ForEach(0 ..< 3, id: \.self) { index in
        Circle()
          .fill(Color.secondary.opacity(0.7))
          .frame(width: 7, height: 7)
          .scaleEffect(isAnimating ? 1 : 0.72)
          .opacity(isAnimating ? 1 : 0.4)
          .animation(
            .easeInOut(duration: 0.55)
              .repeatForever()
              .delay(Double(index) * 0.16),
            value: isAnimating
          )
      }
    }
    .frame(height: 18)
    .onAppear {
      isAnimating = true
    }
  }
}
