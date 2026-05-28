import SwiftUI

struct SelectableItemRow: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))

        Text(title)
          .foregroundStyle(.primary)

        Spacer()
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}
