import SwiftUI

struct InlineAddItemField: View {
  @Binding var text: String
  var isFocused: FocusState<Bool>.Binding
  let onAdd: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      TextField("Add new item…", text: $text)
        .font(.body)
        .textFieldStyle(.plain)
        .focused(isFocused)
        .submitLabel(.done)
        .onSubmit(onAdd)

      Button(action: onAdd) {
        Image(systemName: "plus")
          .font(.headline.weight(.semibold))
          .frame(width: 34, height: 34)
          .background(Color.accentColor.opacity(0.14), in: Circle())
      }
      .accessibilityLabel("Add item")
    }
    .frame(minHeight: 54)
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
    .background(
      Color(uiColor: .secondarySystemGroupedBackground),
      in: RoundedRectangle(cornerRadius: 20)
    )
  }
}
