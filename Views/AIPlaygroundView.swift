import SwiftUI

struct AIPlaygroundView: View {
  @State private var viewModel = AIPlaygroundViewModel()

  var body: some View {
    @Bindable var bindableViewModel = viewModel

    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          if viewModel.messages.isEmpty {
            ContentUnavailableView(
              "Start a Conversation",
              systemImage: "sparkles.rectangle.stack",
              description: Text("Send a prompt to begin chatting with the AI service.")
            )
            .frame(maxWidth: .infinity, minHeight: 420)
            .padding(.horizontal, 16)
            .padding(.top, 24)
          } else {
            LazyVStack(spacing: 12) {
              ForEach(viewModel.messages) { message in
                ChatMessageBubble(message: message)
                  .id(message.id)
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
          }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .safeAreaInset(edge: .bottom) {
          ChatComposerBar(
            text: $bindableViewModel.prompt,
            isSending: viewModel.isGenerating,
            canSend: viewModel.canSend,
            onSend: viewModel.sendPrompt
          )
        }
        .onChange(of: viewModel.messages.count) {
          guard let lastMessage = viewModel.messages.last else { return }
          withAnimation(.smooth) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
          }
        }
      }
      .navigationTitle("AI Playground")
    }
  }
}
