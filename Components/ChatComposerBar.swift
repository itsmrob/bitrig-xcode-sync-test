import SwiftUI

struct ChatComposerBar: View {
  @Binding var text: String
  let isFocused: FocusState<Bool>.Binding
  let isSending: Bool
  let canSend: Bool
  let onSend: () -> Void

  var body: some View {
    HStack {
      HStack(spacing: 10) {
        TextField("Ask anything...", text: $text)
          .font(.body)
          .focused(isFocused)
          .submitLabel(.send)
          .onSubmit {
            guard canSend else { return }
            onSend()
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
          .frame(width: 36, height: 36)
          .foregroundStyle(.white)
          .background(
            Circle()
              .fill(canSend ? Color.accentColor : Color(uiColor: .systemGray3))
          )
        }
        .buttonStyle(.plain)
        .disabled(!canSend)
        .accessibilityLabel(isSending ? "Sending" : "Send")
      }
      .padding(.leading, 16)
      .padding(.trailing, 8)
      .frame(height: 52)
      .background(
        RoundedRectangle(cornerRadius: 26, style: .continuous)
          .fill(Color(uiColor: .secondarySystemBackground))
          .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
      )
      .overlay {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
          .stroke(Color(uiColor: .separator).opacity(0.08), lineWidth: 1)
      }
    }
    .padding(.horizontal, 16)
    .padding(.top, 8)
    .padding(.bottom, 8)
    .background(.ultraThinMaterial)
  }
}
