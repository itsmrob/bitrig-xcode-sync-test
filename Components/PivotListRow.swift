import SwiftUI

struct PivotListRow: View {
  let pivot: Pivot
  let summary: String

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(pivot.title)
        .font(.headline)

      Text(summary)
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(2)

      Text("\(pivot.currentItems.count) Current · \(pivot.optionItems.count) Option\(pivot.optionItems.count == 1 ? "" : "s")")
        .font(.footnote)
        .foregroundStyle(.tertiary)
    }
    .padding(.vertical, 4)
  }
}
