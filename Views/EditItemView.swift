import SwiftUI

struct EditItemView: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var viewModel: BOMViewModel

  let itemID: UUID

  @State private var title = ""
  @State private var selectedGroupType: GroupType = .current
  @State private var selectedCategoryID: BOMCategoryID = .production
  @State private var validationMessage: String?
  @State private var showingDeleteAlert = false
  @State private var hasLoaded = false
  @FocusState private var isTitleFocused: Bool

  private var item: BOMItem? {
    viewModel.item(with: itemID)
  }

  var body: some View {
    Group {
      if let item {
        Form {
          Section("Item") {
            TextField("Item name", text: $title)
              .focused($isTitleFocused)
              .submitLabel(.done)
              .onSubmit(save)
          }

          Section("Details") {
            Picker("Group type", selection: $selectedGroupType) {
              ForEach(GroupType.allCases) { groupType in
                Text(groupType.title).tag(groupType)
              }
            }

            Picker("Category", selection: $selectedCategoryID) {
              ForEach(viewModel.categories, id: \.key) { category in
                Text(category.name).tag(category.key)
              }
            }
          }

          if let validationMessage {
            Section {
              Text(validationMessage)
                .font(.footnote)
                .foregroundStyle(.red)
            }
          }

          Section {
            Button("Save Changes", action: save)
              .fontWeight(.semibold)
          }

          Section {
            Button("Delete Item", role: .destructive) {
              showingDeleteAlert = true
            }
          } footer: {
            Text("Created \(item.createdAt.formatted(DateFormatters.itemTimestamp))")
          }
        }
        .navigationTitle("Edit Item")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Item?", isPresented: $showingDeleteAlert) {
          Button("Cancel", role: .cancel) {}
          Button("Delete", role: .destructive) {
            viewModel.deleteItem(id: itemID)
            dismiss()
          }
        } message: {
          Text("Existing pivots will keep their saved snapshots.")
        }
        .onAppear {
          load(item: item)
        }
      } else {
        ContentUnavailableView(
          "Item Unavailable",
          systemImage: "trash.slash",
          description: Text("This item was removed.")
        )
      }
    }
  }

  private func load(item: BOMItem) {
    guard !hasLoaded else { return }
    title = item.title
    selectedGroupType = item.groupType
    selectedCategoryID = BOMCategoryID(rawValue: item.categoryId) ?? .production
    hasLoaded = true
    isTitleFocused = true
  }

  private func save() {
    do {
      try viewModel.updateItem(
        id: itemID,
        title: title,
        groupType: selectedGroupType,
        categoryId: selectedCategoryID
      )
      dismiss()
    } catch {
      validationMessage = error.localizedDescription
    }
  }
}
