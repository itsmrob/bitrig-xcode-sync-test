import SwiftUI

struct AIPlaygroundView: View {
  @State private var viewModel = AIPlaygroundViewModel()
  @FocusState private var isComposerFocused: Bool

  var body: some View {
    @Bindable var bindableViewModel = viewModel

    NavigationStack {
      ScrollViewReader { proxy in
        ScrollView {
          VStack(spacing: 18) {
            headerView

            if viewModel.messages.isEmpty {
              VStack(spacing: 18) {
                ZStack {
                  Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 78, height: 78)

                  Image(systemName: "sparkles")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                }

                VStack(spacing: 8) {
                  Text("Start a conversation")
                    .font(.title3.weight(.semibold))

                  Text("Ask anything and get instant AI responses")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
              }
              .frame(maxWidth: .infinity, minHeight: 420)
              .padding(.horizontal, 24)
            } else {
              LazyVStack(spacing: 16) {
                ForEach(viewModel.messages) { message in
                  ChatMessageBubble(message: message)
                    .id(message.id)
                }
              }
              .frame(maxWidth: .infinity, alignment: .leading)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.top, 16)
          .padding(.bottom, 12)
        }
        .background(backgroundView.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .safeAreaInset(edge: .bottom) {
          ChatComposerBar(
            text: $bindableViewModel.prompt,
            isFocused: $isComposerFocused,
            isSending: viewModel.isGenerating,
            canSend: viewModel.canSend,
            onSend: handleSend
          )
        }
        .onChange(of: viewModel.messages.count) {
          guard let lastMessage = viewModel.messages.last else { return }
          withAnimation(.smooth) {
            proxy.scrollTo(lastMessage.id, anchor: .bottom)
          }
        }
      }
      .toolbar(.hidden, for: .navigationBar)
    }
  }

  private var headerView: some View {
    VStack(spacing: 6) {
      Text("AI Playground")
        .font(.title2.weight(.bold))

      Text("Prototype prompts, preview responses, and keep lightweight history.")
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(.top, 4)
  }

  private var backgroundView: some View {
    LinearGradient(
      colors: [
        Color(uiColor: .systemBackground),
        Color(uiColor: .systemGroupedBackground)
      ],
      startPoint: .top,
      endPoint: .bottom
    )
  }

  private func handleSend() {
    isComposerFocused = false
    viewModel.sendPrompt()
  }
}
