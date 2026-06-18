import SwiftUI

struct ChatMessageBubble: View {
  let message: ChatMessage

  var body: some View {
    HStack(alignment: .bottom, spacing: 10) {
      if message.role == .assistant {
        roleBadge
      }

      if message.role == .user {
        Spacer(minLength: 56)
      }

      VStack(alignment: bubbleAlignment, spacing: 8) {
        Text(roleTitle)
          .font(.caption.weight(.semibold))
          .foregroundStyle(.secondary)

        if message.state == .loading {
          HStack(spacing: 10) {
            ProgressView()
              .controlSize(.small)

            Text("Thinking…")
              .font(.subheadline)
          }
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .leading)
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
      .frame(maxWidth: 284, alignment: bubbleFrameAlignment)
      .padding(.horizontal, 14)
      .padding(.vertical, 12)
      .background(bubbleBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
          .stroke(borderColor, lineWidth: 1)
      }
      .shadow(color: shadowColor, radius: 10, y: 4)

      if message.role == .user {
        roleBadge
      } else {
        Spacer(minLength: 56)
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

  private var bubbleFrameAlignment: Alignment {
    message.role == .user ? .trailing : .leading
  }

  private var roleTitle: String {
    switch message.role {
    case .user:
      return "You"
    case .assistant:
      return message.state == .error ? "AI Error" : "AI"
    }
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
      return .red.opacity(0.3)
    }

    return message.role == .user
      ? .accentColor.opacity(0.2)
      : Color(uiColor: .separator).opacity(0.16)
  }

  private var shadowColor: Color {
    message.role == .user
      ? .accentColor.opacity(0.16)
      : .black.opacity(0.06)
  }

  private var roleBadge: some View {
    Image(systemName: message.role == .user ? "person.fill" : "sparkles")
      .font(.caption.weight(.bold))
      .foregroundStyle(message.role == .user ? .white : .accentColor)
      .frame(width: 28, height: 28)
      .background(badgeBackground, in: Circle())
  }

  private var badgeBackground: Color {
    switch message.role {
    case .user:
      return .accentColor
    case .assistant:
      return Color(uiColor: .secondarySystemGroupedBackground)
    }
  }
}
