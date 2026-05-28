import SwiftUI

struct InlineAddItemField: View {
  @Binding var text: String
  var isFocused: FocusState<Bool>.Binding
  let onAdd: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      TextField("Add new item…", text: $text)
        .textFieldStyle(.plain)
        .focused(isFocused)
        .submitLabel(.done)
        .onSubmit(onAdd)

      Button(action: onAdd) {
        Image(systemName: "plus")
          .font(.headline.weight(.semibold))
          .frame(width: 30, height: 30)
          .background(Color.accentColor.opacity(0.14), in: Circle())
      }
      .accessibilityLabel("Add item")
    }
    .padding(.horizontal, 14)
    .padding(.vertical, 12)
    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
  }
}
