import SwiftUI

struct PivotsView: View {
  @EnvironmentObject private var viewModel: BOMViewModel
  @State private var searchText = ""
  @State private var isShowingSaveSuccessBanner = false

  private var pivots: [Pivot] {
    viewModel.filteredPivots(searchText: searchText)
  }

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        if viewModel.hasUnsavedPivotChanges {
          BOMSaveBar(
            isSaving: viewModel.isSavingPivots,
            errorMessage: viewModel.pivotSaveErrorMessage,
            onSave: {
              Task {
                await savePivots()
              }
            }
          )
          .padding(.horizontal)
          .padding(.top, 8)
          .transition(.opacity.combined(with: .move(edge: .top)))
        }

        List {
          if pivots.isEmpty {
            ContentUnavailableView(
              searchText.isEmpty ? "No Pivots Yet" : "No Matching Pivots",
              systemImage: searchText.isEmpty ? "square.stack.3d.up" : "magnifyingglass",
              description: Text(
                searchText.isEmpty
                  ? "Create a pivot from your Current items."
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
      }
      .navigationTitle("Pivots")
      .searchable(text: $searchText, prompt: "Search pivots")
      .overlay(alignment: .top) {
        if isShowingSaveSuccessBanner {
          Text("Pivots saved successfully")
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(uiColor: .secondarySystemBackground), in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
            .padding(.top, 10)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
      }
      .task {
        await viewModel.loadPivotsIfNeeded()
      }
    }
  }

  private func savePivots() async {
    let wasSuccessful = await viewModel.savePivots()
    guard wasSuccessful else { return }

    withAnimation(.snappy) {
      isShowingSaveSuccessBanner = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      withAnimation(.snappy) {
        isShowingSaveSuccessBanner = false
      }
    }
  }
}
