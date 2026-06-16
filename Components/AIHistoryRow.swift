import SwiftUI

struct AIHistoryRow: View {
  let entry: AIPlaygroundHistoryEntry

  var body: some View {
    PlaygroundCard {
      VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .top, spacing: 12) {
          Text(entry.prompt)
            .font(.headline)
            .foregroundStyle(.primary)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)

          Text(entry.createdAt, format: DateFormatters.aiPlaygroundTimestamp)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.trailing)
        }

        Text(entry.responsePreview)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(3)
      }
    }
  }
}
