import SwiftUI

struct PivotsView: View {
  @EnvironmentObject private var viewModel: BOMViewModel
  @State private var searchText = ""

  private var pivots: [Pivot] {
    viewModel.filteredPivots(searchText: searchText)
  }

  var body: some View {
    NavigationStack {
      List {
        if pivots.isEmpty {
          ContentUnavailableView(
            searchText.isEmpty ? "No Pivots Yet" : "No Matching Pivots",
            systemImage: searchText.isEmpty ? "square.stack.3d.up" : "magnifyingglass",
            description: Text(
              searchText.isEmpty
                ? "Create a pivot from your Current and Option items."
                : "Try a different search term."
            )
          )
        } else {
          ForEach(pivots) { pivot in
            NavigationLink {
              PivotDetailView(pivotID: pivot.id)
            } label: {
              PivotListRow(
                pivot: pivot,
                summary: viewModel.previewSummary(for: pivot)
              )
            }
            .swipeActions {
              Button("Delete", systemImage: "trash", role: .destructive) {
                withAnimation {
                  viewModel.deletePivot(id: pivot.id)
                }
              }
            }
          }
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Pivots")
      .searchable(text: $searchText, prompt: "Search pivots")
    }
  }
}
