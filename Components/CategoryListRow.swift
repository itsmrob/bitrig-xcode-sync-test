import SwiftUI

struct CategoryListRow: View {
  let category: Category
  let count: Int

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: category.symbol)
        .font(.body.weight(.semibold))
        .foregroundStyle(category.color)
        .frame(width: 28, height: 28)
        .background(category.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

      Text(category.name)
        .font(.body)

      Spacer()

      Text("\(count)")
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
    .padding(.vertical, 4)
  }
}
