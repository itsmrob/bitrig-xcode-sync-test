import SwiftUI

struct CreatePivotView: View {
  @EnvironmentObject private var viewModel: BOMViewModel

  @State private var expandedCurrentCategoryID: String?
  @State private var expandedOptionCategoryID: String?
  @State private var errorMessage: String?
  @State private var showingSuccessAlert = false
  @State private var feedbackTrigger = 0

  private var currentGroups: [CategoryItemGroup] {
    viewModel.groupedItems(for: .current)
  }

  private var optionGroups: [CategoryItemGroup] {
    viewModel.groupedItems(for: .options)
  }

  var body: some View {
    NavigationStack {
      List {
        Section {
          Text("Select at least one Current item and one Option item.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }

        if currentGroups.isEmpty && optionGroups.isEmpty {
          Section {
            ContentUnavailableView(
              "No Items Yet",
              systemImage: "arrow.triangle.branch",
              description: Text("Add Current and Option items in Inputs before creating a pivot.")
            )
          }
        } else {
          if !currentGroups.isEmpty {
            Section("Current") {
              ForEach(currentGroups) { group in
                DisclosureGroup(
                  isExpanded: currentBinding(for: group.category.id)
                ) {
                  ForEach(group.items) { item in
                    SelectableItemRow(
                      title: item.title,
                      isSelected: viewModel.isSelected(item)
                    ) {
                      withAnimation(.snappy) {
                        viewModel.toggleSelection(for: item)
                        errorMessage = nil
                      }
                    }
                  }
                } label: {
                  HStack {
                    CategoryListRow(
                      category: group.category,
                      count: group.items.count
                    )

                    Spacer()

                    let selectedCount = viewModel.selectedCount(for: group.category, groupType: .current)
                    if selectedCount > 0 {
                      Text("\(selectedCount) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                  }
                }
              }
            }
          }

          if !optionGroups.isEmpty {
            Section("Options") {
              ForEach(optionGroups) { group in
                DisclosureGroup(
                  isExpanded: optionBinding(for: group.category.id)
                ) {
                  ForEach(group.items) { item in
                    SelectableItemRow(
                      title: item.title,
                      isSelected: viewModel.isSelected(item)
                    ) {
                      withAnimation(.snappy) {
                        viewModel.toggleSelection(for: item)
                        errorMessage = nil
                      }
                    }
                  }
                } label: {
                  HStack {
                    CategoryListRow(
                      category: group.category,
                      count: group.items.count
                    )

                    Spacer()

                    let selectedCount = viewModel.selectedCount(for: group.category, groupType: .options)
                    if selectedCount > 0 {
                      Text("\(selectedCount) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                  }
                }
              }
            }
          }
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Create Pivot")
      .safeAreaInset(edge: .bottom) {
        VStack(spacing: 8) {
          Button("Create Pivot", action: createPivot)
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(!viewModel.canCreatePivot)

          Text(errorMessage ?? helperText)
            .font(.footnote)
            .foregroundStyle(
              errorMessage == nil
                ? AnyShapeStyle(.secondary)
                : AnyShapeStyle(.red)
            )
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
      }
      .alert("Pivot Created", isPresented: $showingSuccessAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text("Your new pivot is now available in Pivots.")
      }
      .sensoryFeedback(.success, trigger: feedbackTrigger)
      .onAppear {
        expandedCurrentCategoryID = expandedCurrentCategoryID ?? currentGroups.first?.category.id
        expandedOptionCategoryID = expandedOptionCategoryID ?? optionGroups.first?.category.id
      }
    }
  }

  private var helperText: String {
    if viewModel.canCreatePivot {
      return viewModel.selectionSummaryText()
    }

    return "Select at least one Current item and one Option item."
  }

  private func currentBinding(for categoryID: String) -> Binding<Bool> {
    Binding {
      expandedCurrentCategoryID == categoryID
    } set: { isExpanded in
      expandedCurrentCategoryID = isExpanded ? categoryID : nil
    }
  }

  private func optionBinding(for categoryID: String) -> Binding<Bool> {
    Binding {
      expandedOptionCategoryID == categoryID
    } set: { isExpanded in
      expandedOptionCategoryID = isExpanded ? categoryID : nil
    }
  }

  private func createPivot() {
    do {
      try viewModel.createPivot()
      errorMessage = nil
      feedbackTrigger += 1
      showingSuccessAlert = true
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
