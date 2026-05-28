import SwiftUI

struct RenamePivotView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var viewModel: BOMViewModel

  let pivotID: UUID

  @State private var title = ""
  @State private var validationMessage: String?
  @FocusState private var isTitleFocused: Bool

  private var pivot: Pivot? {
    viewModel.pivot(with: pivotID)
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Pivot Name") {
          TextField("Name", text: $title)
            .focused($isTitleFocused)
            .submitLabel(.done)
            .onSubmit(save)
        }

        if let validationMessage {
          Section {
            Text(validationMessage)
              .font(.footnote)
              .foregroundStyle(.red)
          }
        }
      }
      .navigationTitle("Rename Pivot")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button("Save", action: save)
            .fontWeight(.semibold)
        }
      }
      .onAppear {
        title = pivot?.title ?? ""
        isTitleFocused = true
      }
    }
  }

  private func save() {
    do {
      try viewModel.renamePivot(id: pivotID, title: title)
      dismiss()
    } catch {
      validationMessage = error.localizedDescription
    }
  }
}
