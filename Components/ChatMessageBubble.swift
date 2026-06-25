import SwiftUI

struct ChatMessageBubble: View {
  let message: ChatMessage

  var body: some View {
    VStack(alignment: rowAlignment, spacing: 4) {
      HStack {
        if message.role == .user {
          Spacer(minLength: 64)
        }

        bubbleContent

        if message.role == .assistant {
          Spacer(minLength: 64)
        }
      }

      HStack {
        if message.role == .user {
          Spacer()
        }

        Text(message.createdAt, format: DateFormatters.aiPlaygroundTimestamp)
          .font(.caption2)
          .foregroundStyle(.tertiary)

        if message.role == .assistant {
          Spacer()
        }
      }
    }
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder
  private var bubbleContent: some View {
    Group {
      if message.state == .loading {
        ChatTypingIndicator()
          .frame(maxWidth: .infinity, alignment: .leading)
      } else {
        Text(message.text)
          .font(.body)
          .foregroundStyle(textColor)
          .textSelection(.enabled)
          .frame(maxWidth: .infinity, alignment: textAlignment)
      }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 13)
    .frame(maxWidth: 290, alignment: bubbleFrameAlignment)
    .background(bubbleBackground, in: RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: bubbleCornerRadius, style: .continuous)
        .stroke(borderColor, lineWidth: 0.8)
    }
    .shadow(color: shadowColor, radius: 12, y: 6)
  }

  private var textAlignment: Alignment {
    message.role == .user ? .trailing : .leading
  }

  private var bubbleFrameAlignment: Alignment {
    message.role == .user ? .trailing : .leading
  }

  private var rowAlignment: HorizontalAlignment {
    message.role == .user ? .trailing : .leading
  }

  private var bubbleCornerRadius: CGFloat {
    22
  }

  private var bubbleBackground: Color {
    switch message.role {
    case .user:
      return .accentColor
    case .assistant:
      if message.state == .error {
        return Color.red.opacity(0.08)
      }

      return Color(uiColor: .secondarySystemBackground)
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
      return .red.opacity(0.18)
    }

    return message.role == .user
      ? .accentColor.opacity(0.1)
      : Color(uiColor: .separator).opacity(0.08)
  }

  private var shadowColor: Color {
    message.role == .user
      ? .accentColor.opacity(0.18)
      : .black.opacity(0.05)
  }
}
