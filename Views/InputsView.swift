import SwiftUI

struct InputsView: View {
  @EnvironmentObject private var viewModel: BOMViewModel
  @State private var selectedGroup: GroupType = .current

  var body: some View {
    NavigationStack {
      VStack(alignment: .leading, spacing: 14) {
        VStack(alignment: .leading, spacing: 10) {
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
        .padding(.horizontal)
        .padding(.top, 8)

        List {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
      .navigationTitle("Inputs")
    }
    .listStyle(.insetGrouped)
    .contentMargins(.top, 0, for: .scrollContent)
  }
}
