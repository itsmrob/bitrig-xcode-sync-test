import SwiftUI

struct BOMSaveBar: View {
  let isSaving: Bool
  let errorMessage: String?
  let onSave: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 10) {
        Circle()
          .fill(Color.orange)
          .frame(width: 8, height: 8)

        Text("Unsaved changes")
          .font(.subheadline.weight(.semibold))

        Spacer()

        Button(action: onSave) {
          HStack(spacing: 8) {
            if isSaving {
              ProgressView()
                .tint(.white)
            }

            Text(isSaving ? "Saving…" : "Save")
              .font(.subheadline.weight(.semibold))
          }
          .padding(.horizontal, 14)
          .padding(.vertical, 9)
          .foregroundStyle(.white)
          .background(Color.accentColor, in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
      }

      if let errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundStyle(.red)
      }
    }
    .padding(14)
    .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    .shadow(color: .black.opacity(0.12), radius: 14, y: 6)
  }
}
