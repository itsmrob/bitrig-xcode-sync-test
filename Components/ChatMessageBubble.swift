import SwiftUI

struct ChatMessageBubble: View {
  let message: ChatMessage

  var body: some View {
    HStack {
      if message.role == .user {
        Spacer(minLength: 48)
      }

      VStack(alignment: bubbleAlignment, spacing: 8) {
        if message.state == .loading {
          HStack(spacing: 10) {
            ProgressView()
              .controlSize(.small)

            Text("Thinking…")
              .font(.subheadline)
          }
          .foregroundStyle(.secondary)
        } else {
          Text(message.text)
            .font(.body)
            .foregroundStyle(textColor)
            .textSelection(.enabled)
            .frame(maxWidth: .infinity, alignment: textAlignment)
        }

        Text(message.createdAt, format: DateFormatters.aiPlaygroundTimestamp)
          .font(.caption2)
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: 280, alignment: bubbleAlignment == .trailing ? .trailing : .leading)
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(bubbleBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(borderColor, lineWidth: 1)
      }

      if message.role == .assistant {
        Spacer(minLength: 48)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private var bubbleAlignment: HorizontalAlignment {
    message.role == .user ? .trailing : .leading
  }

  private var textAlignment: Alignment {
    message.role == .user ? .trailing : .leading
  }

  private var bubbleBackground: Color {
    switch message.role {
    case .user:
      return .accentColor
    case .assistant:
      return Color(uiColor: .secondarySystemGroupedBackground)
    }
  }

  private var textColor: Color {
    if message.state == .error {
      return .red
    }

    return message.role == .user ? .white : .primary
  }

  private var borderColor: Color {
    if message.state == .error {
      return .red.opacity(0.25)
    }

    return message.role == .user
      ? .accentColor.opacity(0.2)
      : Color(uiColor: .separator).opacity(0.16)
  }
}
