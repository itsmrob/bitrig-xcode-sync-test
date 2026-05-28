import SwiftUI

struct InputsView: View {
  @EnvironmentObject private var viewModel: BOMViewModel
  @State private var selectedGroup: GroupType = .current

  var body: some View {
    NavigationStack {
      List {
        Section {
          Text("Manage your Current and Option items.")
            .font(.subheadline)
            .foregroundStyle(.secondary)

          Picker("Group", selection: $selectedGroup) {
            ForEach(GroupType.allCases) { groupType in
              Text(groupType.title).tag(groupType)
            }
          }
          .pickerStyle(.segmented)
        }

        Section {
          ForEach(viewModel.categories) { category in
            NavigationLink {
              CategoryDetailView(category: category, groupType: selectedGroup)
            } label: {
              CategoryListRow(
                category: category,
                count: viewModel.itemCount(for: category, groupType: selectedGroup)
              )
            }
          }
        } header: {
          Text("Categories")
        } footer: {
          Text("Select a category to manage its \(selectedGroup.title.lowercased()) items.")
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Inputs")
    }
  }
}
