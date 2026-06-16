import SwiftUI

struct PromptInputCard: View {
  let title: String
  let placeholder: String
  @Binding var text: String

  var body: some View {
    PlaygroundCard {
      VStack(alignment: .leading, spacing: 12) {
        Text(title)
          .font(.headline)

        ZStack(alignment: .topLeading) {
          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(uiColor: .tertiarySystemGroupedBackground))

          RoundedRectangle(cornerRadius: 18, style: .continuous)
            .stroke(Color(uiColor: .separator).opacity(0.18), lineWidth: 1)

          TextEditor(text: $text)
            .font(.body)
            .frame(minHeight: 180)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .scrollContentBackground(.hidden)
            .background(.clear)

          if text.isEmpty {
            Text(placeholder)
              .foregroundStyle(.tertiary)
              .padding(.horizontal, 16)
              .padding(.vertical, 20)
              .allowsHitTesting(false)
          }
        }
      }
    }
  }
}
