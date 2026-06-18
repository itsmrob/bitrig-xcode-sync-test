import SwiftUI

struct AIResponseCard: View {
  let entry: AIPlaygroundHistoryEntry?
  let isGenerating: Bool

  var body: some View {
    PlaygroundCard {
      VStack(alignment: .leading, spacing: 14) {
        Text("Response")
          .font(.headline)

        if isGenerating {
          VStack(spacing: 12) {
            ProgressView()
              .controlSize(.large)

            Text("Generating preview…")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .frame(maxWidth: .infinity, minHeight: 180)
        } else if let entry {
          ScrollView {
            Text(entry.response)
              .font(.body)
              .foregroundStyle(entry.isError ? .red : .primary)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .frame(minHeight: 180, maxHeight: 260)
        } else {
          ContentUnavailableView(
            "No Response Yet",
            systemImage: "text.bubble",
            description: Text("Generate a prompt to preview where AI output will appear.")
          )
          .frame(maxWidth: .infinity, minHeight: 180)
        }
      }
    }
  }
}
