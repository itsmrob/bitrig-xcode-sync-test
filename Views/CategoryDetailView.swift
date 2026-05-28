import SwiftUI

struct CategoryDetailView: View {
  @EnvironmentObject private var viewModel: BOMViewModel

  let category: Category
  let groupType: GroupType

  @State private var newItemTitle = ""
  @State private var searchText = ""
  @State private var errorMessage: String?
  @State private var editingItemID: UUID?
  @FocusState private var isInputFocused: Bool

  private var categoryItems: [BOMItem] {
    viewModel.items(for: category, groupType: groupType, searchText: searchText)
  }

  var body: some View {
    List {
      Section {
        InlineAddItemField(
          text: $newItemTitle,
          isFocused: $isInputFocused,
          onAdd: addItem
        )
        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: errorMessage == nil ? 2 : 6, trailing: 20))

        if let errorMessage {
          Text(errorMessage)
            .font(.footnote)
            .foregroundStyle(.red)
        }
      }

      if categoryItems.isEmpty {
        Section {
          ContentUnavailableView(
            searchText.isEmpty ? "No \(groupType.title) Items" : "No Matches",
            systemImage: searchText.isEmpty ? "text.badge.plus" : "magnifyingglass",
            description: Text(
              searchText.isEmpty
                ? "Add items here to build pivots faster."
                : "Try a different search term."
            )
          )
        }
      } else {
        Section("Items") {
          ForEach(categoryItems) { item in
            NavigationLink {
              EditItemView(itemID: item.id)
            } label: {
              Text(item.title)
                .padding(.vertical, 4)
            }
            .contextMenu {
              Button("Edit", systemImage: "pencil") {
                editingItemID = item.id
              }

              Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation {
                  viewModel.deleteItem(id: item.id)
                }
              }
            }
            .swipeActions {
              Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation {
                  viewModel.deleteItem(id: item.id)
                }
              }
            }
          }
        }
      }
    }
    .listStyle(.insetGrouped)
    .listSectionSpacing(.compact)
    .contentMargins(.top, 0, for: .scrollContent)
    .navigationBarTitleDisplayMode(.inline)
    .searchable(text: $searchText, prompt: "Search items")
    .toolbar {
      ToolbarItem(placement: .principal) {
        VStack(spacing: 1) {
          Text(category.name)
            .font(.headline)
          Text(groupType.title)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
    }
    .sheet(
      isPresented: Binding(
        get: { editingItemID != nil },
        set: { isPresented in
          if !isPresented {
            editingItemID = nil
          }
        }
      )
    ) {
      NavigationStack {
        if let editingItemID {
          EditItemView(itemID: editingItemID)
        }
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isInputFocused = true
      }
    }
  }

  private func addItem() {
    do {
      try viewModel.addItem(
        title: newItemTitle,
        groupType: groupType,
        categoryId: category.key
      )
      errorMessage = nil
      newItemTitle = ""
      DispatchQueue.main.async {
        isInputFocused = true
      }
    } catch {
      errorMessage = error.localizedDescription
      DispatchQueue.main.async {
        isInputFocused = true
      }
    }
  }
}
