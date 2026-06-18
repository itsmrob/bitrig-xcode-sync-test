import SwiftUI

struct ChatComposerBar: View {
  @Binding var text: String
  let isSending: Bool
  let canSend: Bool
  let onSend: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Divider()
        .opacity(0.5)

      HStack(alignment: .bottom, spacing: 12) {
        ZStack(alignment: .topLeading) {
          RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color(uiColor: .secondarySystemGroupedBackground))

          RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(Color(uiColor: .separator).opacity(0.18), lineWidth: 1)

          TextEditor(text: $text)
            .font(.body)
            .frame(minHeight: 46, maxHeight: 108)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .scrollContentBackground(.hidden)
            .background(.clear)

          if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text("Ask anything...")
              .foregroundStyle(.tertiary)
              .padding(.horizontal, 16)
              .padding(.vertical, 20)
              .allowsHitTesting(false)
          }
        }

        Button(action: onSend) {
          Group {
            if isSending {
              ProgressView()
                .tint(.white)
            } else {
              Image(systemName: "arrow.up")
                .font(.headline.weight(.semibold))
            }
          }
          .frame(width: 48, height: 48)
          .foregroundStyle(.white)
          .background(
            Circle()
              .fill(canSend ? Color.accentColor : Color(uiColor: .systemGray3))
          )
          .shadow(color: canSend ? .accentColor.opacity(0.2) : .clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .accessibilityLabel(isSending ? "Sending" : "Send")
      }
      .padding(.horizontal, 16)
      .padding(.top, 12)
      .padding(.bottom, 8)
      .background(Color(uiColor: .systemGroupedBackground))
    }
    .background(.regularMaterial)
  }
}
