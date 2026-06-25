import SwiftUI

struct AIAutofillSheet: View {
  @ObservedObject var viewModel: BOMAutofillViewModel

  let onGenerate: () -> Void
  let onCancel: () -> Void

  @FocusState private var isPromptFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      VStack(alignment: .leading, spacing: 6) {
        Text("Fill with AI")
          .font(.title3.weight(.semibold))

        Text("Describe your business and AI will generate Current and Options items.")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      promptCard

      if viewModel.isGenerating {
        loadingCard
      }

      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .font(.footnote)
          .foregroundStyle(.red)
      }

      HStack(spacing: 12) {
        Button("Cancel") {
          isPromptFocused = false
          onCancel()
        }
        .buttonStyle(.bordered)
        .controlSize(.large)

        Button {
          isPromptFocused = false
          onGenerate()
        } label: {
          HStack(spacing: 8) {
            if viewModel.isGenerating {
              ProgressView()
                .tint(.white)
            }
            Text(viewModel.isGenerating ? "Generating…" : "Generate")
              .fontWeight(.semibold)
          }
          .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(!viewModel.canGenerate)
      }
    }
    .padding(20)
    .presentationDetents([.height(430)])
    .presentationDragIndicator(.visible)
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        isPromptFocused = true
      }
    }
  }

  private var promptCard: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Business Prompt")
        .font(.subheadline.weight(.medium))

      ZStack(alignment: .topLeading) {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .fill(Color(uiColor: .secondarySystemGroupedBackground))

        RoundedRectangle(cornerRadius: 18, style: .continuous)
          .stroke(Color(uiColor: .separator).opacity(0.18), lineWidth: 1)

        TextEditor(text: $viewModel.prompt)
          .font(.body)
          .focused($isPromptFocused)
          .frame(minHeight: 120, maxHeight: 130)
          .padding(.horizontal, 10)
          .padding(.vertical, 8)
          .scrollContentBackground(.hidden)
          .background(.clear)

        if viewModel.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
          Text("Example: We run a coffee shop and want to improve delivery, customer experience, and revenue.")
            .font(.body)
            .foregroundStyle(.tertiary)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .allowsHitTesting(false)
        }
      }
    }
  }

  private var loadingCard: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(spacing: 10) {
        ProgressView()
          .controlSize(.regular)

        Text("Generating your business map…")
          .font(.subheadline.weight(.medium))
      }

      VStack(alignment: .leading, spacing: 6) {
        loadingStep("Analyzing business")
        loadingStep("Creating Current items")
        loadingStep("Creating Options items")
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
  }

  private func loadingStep(_ title: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: "sparkles")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.tint)

      Text(title)
        .font(.footnote)
        .foregroundStyle(.secondary)
    }
  }
}
