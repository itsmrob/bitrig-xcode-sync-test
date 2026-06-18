import SwiftUI

struct ChatComposerBar: View {
  @Binding var text: String
  let isFocused: FocusState<Bool>.Binding
  let isSending: Bool
  let canSend: Bool
  let onSend: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        ZStack(alignment: .trailing) {
          RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color(uiColor: .secondarySystemBackground))
            .shadow(color: .black.opacity(0.06), radius: 14, y: 6)

          RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(Color(uiColor: .separator).opacity(0.08), lineWidth: 1)

          TextField("Ask anything...", text: $text, axis: .vertical)
            .font(.body)
            .focused(isFocused)
            .lineLimit(1 ... 4)
            .padding(.leading, 14)
            .padding(.trailing, 62)
            .padding(.vertical, 14)

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
            .frame(width: 40, height: 40)
            .foregroundStyle(.white)
            .background(
              Circle()
                .fill(canSend ? Color.accentColor : Color(uiColor: .systemGray3))
            )
            .shadow(color: canSend ? .accentColor.opacity(0.25) : .clear, radius: 10, y: 4)
          }
          .buttonStyle(.plain)
          .disabled(!canSend)
          .accessibilityLabel(isSending ? "Sending" : "Send")
          .padding(.trailing, 8)
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 8)
      .padding(.bottom, 8)
    }
    .background(.ultraThinMaterial)
  }
}
