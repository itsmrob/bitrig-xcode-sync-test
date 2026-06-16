import SwiftUI

struct PlaygroundCard<Content: View>: View {
  @ViewBuilder var content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(18)
    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    .overlay {
      RoundedRectangle(cornerRadius: 22, style: .continuous)
        .stroke(Color(uiColor: .separator).opacity(0.16), lineWidth: 1)
    }
  }
}
