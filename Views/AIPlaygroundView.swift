import SwiftUI

struct AIPlaygroundView: View {
  @State private var viewModel = AIPlaygroundViewModel()

  var body: some View {
    @Bindable var bindableViewModel = viewModel

    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 22) {
          VStack(alignment: .leading, spacing: 6) {
            Text("Prototype prompts, preview responses, and keep lightweight history before wiring in a live AI backend.")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }

          PromptInputCard(
            title: "Prompt",
            placeholder: "Ask anything...",
            text: $bindableViewModel.prompt
          )

          Button {
            viewModel.generate()
          } label: {
            HStack(spacing: 10) {
              if viewModel.isGenerating {
                ProgressView()
                  .tint(.white)
              }

              Text(viewModel.isGenerating ? "Generating…" : "Generate")
                .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .foregroundStyle(.white)
            .background(
              RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(viewModel.canGenerate ? Color.accentColor : Color(uiColor: .systemGray3))
            )
          }
          .buttonStyle(.plain)
          .disabled(!viewModel.canGenerate)

          AIResponseCard(
            entry: viewModel.latestEntry,
            isGenerating: viewModel.isGenerating
          )

          VStack(alignment: .leading, spacing: 14) {
            Text("History")
              .font(.title3.weight(.semibold))

            if viewModel.history.isEmpty {
              PlaygroundCard {
                ContentUnavailableView(
                  "No History Yet",
                  systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                  description: Text("Your previous prompts and response previews will appear here.")
                )
                .frame(maxWidth: .infinity, minHeight: 180)
              }
            } else {
              LazyVStack(spacing: 12) {
                ForEach(viewModel.history) { entry in
                  AIHistoryRow(entry: entry)
                }
              }
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
      }
      .background(Color(uiColor: .systemGroupedBackground))
      .navigationTitle("AI Playground")
    }
  }
}
