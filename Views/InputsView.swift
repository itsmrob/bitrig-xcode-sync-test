import SwiftUI

struct InputsView: View {
  @EnvironmentObject private var viewModel: BOMViewModel
  @StateObject private var autofillViewModel = BOMAutofillViewModel()
  @State private var selectedGroup: GroupType = .current
  @State private var isShowingAutofillSheet = false
  @State private var isShowingReplaceConfirmation = false
  @State private var isShowingSuccessToast = false
  @State private var isShowingSaveSuccessBanner = false

  var body: some View {
    NavigationStack {
      ZStack {
        Color(uiColor: .systemGroupedBackground)
          .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 14) {
          if viewModel.hasUnsavedChanges {
            BOMSaveBar(
              isSaving: viewModel.isSaving,
              errorMessage: viewModel.saveErrorMessage,
              onSave: {
                Task {
                  await saveProject()
                }
              }
            )
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.opacity.combined(with: .move(edge: .top)))
          }

          VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Manage your Current and Option items.")
                  .font(.subheadline)
                  .foregroundStyle(.secondary)

                Text("Generate a full business map with AI or keep adding items manually.")
                  .font(.footnote)
                  .foregroundStyle(.tertiary)
              }

              Spacer()

              Button {
                autofillViewModel.resetError()
                isShowingAutofillSheet = true
              } label: {
                HStack(spacing: 6) {
                  Image(systemName: "sparkles")
                    .font(.caption.weight(.semibold))

                  Text("AI Autofill")
                    .font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(.white)
                .background(Color.accentColor, in: Capsule())
              }
              .buttonStyle(.plain)
            }

            Picker("Group", selection: $selectedGroup) {
              ForEach(GroupType.allCases) { groupType in
                Text(groupType.title).tag(groupType)
              }
            }
            .pickerStyle(.segmented)
          }
          .padding(.horizontal)
          .padding(.top, viewModel.hasUnsavedChanges ? 0 : 8)

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
      }
      .navigationTitle("Data Inputs")
      .sheet(isPresented: $isShowingAutofillSheet) {
        AIAutofillSheet(
          viewModel: autofillViewModel,
          onGenerate: requestAutofillGeneration,
          onCancel: {
            autofillViewModel.resetError()
            isShowingAutofillSheet = false
          }
        )
      }
      .alert("Replace Existing Items?", isPresented: $isShowingReplaceConfirmation) {
        Button("Cancel", role: .cancel) {}
        Button("Continue", role: .destructive) {
          Task {
            await runAutofill()
          }
        }
      } message: {
        Text("This will replace existing Current and Options items. Continue?")
      }
      .overlay(alignment: .top) {
        VStack(spacing: 10) {
          if isShowingSuccessToast {
            statusBanner("AI generated data inputs successfully.")
          }

          if isShowingSaveSuccessBanner {
            statusBanner("✓ Changes saved")
          }
        }
      }
    }
    .listStyle(.insetGrouped)
    .contentMargins(.top, 0, for: .scrollContent)
    .task {
      await viewModel.loadProjectIfNeeded()
    }
  }

  private func requestAutofillGeneration() {
    if viewModel.hasItems {
      isShowingReplaceConfirmation = true
    } else {
      Task {
        await runAutofill()
      }
    }
  }

  private func runAutofill() async {
    let wasSuccessful = await autofillViewModel.generateAutofill(into: viewModel)
    guard wasSuccessful else { return }

    isShowingAutofillSheet = false
    showSuccessToast()
  }

  private func showSuccessToast() {
    withAnimation(.snappy) {
      isShowingSuccessToast = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
      withAnimation(.snappy) {
        isShowingSuccessToast = false
      }
    }
  }

  private func saveProject() async {
    let wasSuccessful = await viewModel.saveProject()
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

  private func statusBanner(_ title: String) -> some View {
    Text(title)
      .font(.subheadline.weight(.medium))
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color(uiColor: .secondarySystemBackground), in: Capsule())
      .shadow(color: .black.opacity(0.12), radius: 12, y: 6)
      .padding(.top, 10)
      .transition(.move(edge: .top).combined(with: .opacity))
  }
}
