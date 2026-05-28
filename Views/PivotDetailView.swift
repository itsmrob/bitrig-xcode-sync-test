import SwiftUI

struct PivotDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var viewModel: BOMViewModel

  let pivotID: UUID

  @State private var showingRenameSheet = false
  @State private var showingDeleteEmptyAlert = false

  private var pivot: Pivot? {
    viewModel.pivot(with: pivotID)
  }

  var body: some View {
    Group {
      if let pivot {
        List {
          Section {
            Text(viewModel.detailSummary(for: pivot))
              .font(.body)
          }

          let currentGroups = viewModel.groupedSnapshots(for: pivot, groupType: .current)
          if currentGroups.isEmpty == false {
            ForEach(currentGroups) { group in
              Section("Current • \(group.category.name)") {
                ForEach(group.items) { item in
                  Text(item.title)
                    .swipeActions {
                      Button("Remove", systemImage: "minus.circle", role: .destructive) {
                        let shouldPrompt = viewModel.removeSnapshot(
                          snapshotID: item.id,
                          groupType: .current,
                          from: pivotID
                        )
                        showingDeleteEmptyAlert = shouldPrompt
                      }
                    }
                }
              }
            }
          }

          let optionGroups = viewModel.groupedSnapshots(for: pivot, groupType: .options)
          if optionGroups.isEmpty == false {
            ForEach(optionGroups) { group in
              Section("Options • \(group.category.name)") {
                ForEach(group.items) { item in
                  Text(item.title)
                    .swipeActions {
                      Button("Remove", systemImage: "minus.circle", role: .destructive) {
                        let shouldPrompt = viewModel.removeSnapshot(
                          snapshotID: item.id,
                          groupType: .options,
                          from: pivotID
                        )
                        showingDeleteEmptyAlert = shouldPrompt
                      }
                    }
                }
              }
            }
          }

          if currentGroups.isEmpty && optionGroups.isEmpty {
            Section {
              ContentUnavailableView(
                "No Items in Pivot",
                systemImage: "square.stack.3d.up.slash",
                description: Text("This pivot is empty. You can keep it or delete it.")
              )
            }
          }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(pivot.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Edit") {
              showingRenameSheet = true
            }
          }
        }
        .sheet(isPresented: $showingRenameSheet) {
          RenamePivotView(pivotID: pivotID)
            .presentationDetents([.height(220)])
        }
        .alert("Delete Empty Pivot?", isPresented: $showingDeleteEmptyAlert) {
          Button("Keep Pivot", role: .cancel) {}
          Button("Delete Pivot", role: .destructive) {
            viewModel.deletePivot(id: pivotID)
            dismiss()
          }
        } message: {
          Text("Removing items here only affects this pivot.")
        }
      } else {
        ContentUnavailableView(
          "Pivot Unavailable",
          systemImage: "trash.slash",
          description: Text("This pivot was removed.")
        )
      }
    }
  }
}
