import SwiftUI

struct AIPlaygroundView: View {
  @State private var viewModel = AIPlaygroundViewModel()

  var body: some View {
    @Bindable var bindableViewModel = viewModel

    NavigationStack {
      VStack(spacing: 0) {
        if viewModel.messages.isEmpty {
          VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
              Text("AI Playground")
                .font(.largeTitle.weight(.bold))

              Text("Ask questions, inspect responses, and keep the conversation flowing in a simple chat layout.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
              suggestionRow(icon: "text.bubble", title: "Ask a product question")
              suggestionRow(icon: "doc.text.magnifyingglass", title: "Summarize a paragraph")
              suggestionRow(icon: "lightbulb", title: "Brainstorm ideas")
            }
            .padding(18)
            .background(
              RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
          .padding(.horizontal, 20)
          .padding(.top, 28)
          .background(Color(uiColor: .systemGroupedBackground))
        } else {
          ScrollViewReader { proxy in
            ScrollView {
              LazyVStack(spacing: 14) {
                ForEach(viewModel.messages) { message in
                  ChatMessageBubble(message: message)
                    .id(message.id)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .padding(.vertical, 18)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onChange(of: viewModel.messages.count) {
              guard let lastMessage = viewModel.messages.last else { return }
              withAnimation(.smooth) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
              }
            }
          }
        }
      }
      .safeAreaInset(edge: .bottom) {
        ChatComposerBar(
          text: $bindableViewModel.prompt,
          isSending: viewModel.isGenerating,
          canSend: viewModel.canSend,
          onSend: viewModel.sendPrompt
        )
      }
      .navigationTitle("AI Playground")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  private func suggestionRow(icon: String, title: String) -> some View {
    HStack(spacing: 12) {
      Image(systemName: icon)
        .font(.body.weight(.semibold))
        .foregroundStyle(.tint)
        .frame(width: 32, height: 32)
        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

      Text(title)
        .font(.subheadline)

      Spacer()
    }
  }
}
