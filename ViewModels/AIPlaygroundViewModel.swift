import Foundation
import Observation

@MainActor
@Observable
final class AIPlaygroundViewModel {
  var prompt = ""
  var messages: [ChatMessage] = []
  var isGenerating = false
  var errorMessage: String?

  private let service: AIService

  init(service: AIService = AIService()) {
    self.service = service
  }

  var canSend: Bool {
    !trimmedPrompt.isEmpty && !isGenerating
  }

  func sendPrompt() {
    let submittedPrompt = trimmedPrompt
    guard !submittedPrompt.isEmpty, !isGenerating else { return }

    isGenerating = true
    errorMessage = nil
    prompt = ""

    messages.append(
      ChatMessage(
        id: UUID(),
        role: .user,
        text: submittedPrompt,
        createdAt: Date(),
        state: .sent
      )
    )

    let loadingMessageID = UUID()
    messages.append(
      ChatMessage(
        id: loadingMessageID,
        role: .assistant,
        text: "",
        createdAt: Date(),
        state: .loading
      )
    )

    Task {
      defer { isGenerating = false }

      do {
        // The view model owns the full request lifecycle so the view only reacts to state changes.
        let response = try await service.generateResponse(for: submittedPrompt)
        updateAssistantMessage(
          id: loadingMessageID,
          text: response,
          state: .sent
        )
      } catch {
        let message = formattedErrorMessage(from: error)
        errorMessage = message
        updateAssistantMessage(
          id: loadingMessageID,
          text: message,
          state: .error
        )
      }
    }
  }

  private var trimmedPrompt: String {
    prompt.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func formattedErrorMessage(from error: Error) -> String {
    if let serviceError = error as? AIServiceError {
      return serviceError.errorDescription ?? "Something went wrong while contacting the AI service."
    }

    if let urlError = error as? URLError {
      switch urlError.code {
      case .notConnectedToInternet:
        return "No network connection is available."
      case .timedOut:
        return "The request timed out. Try again."
      case .cannotConnectToHost:
        return "The app could not reach the backend server."
      case .networkConnectionLost:
        return "The network connection was lost during the request."
      default:
        return urlError.localizedDescription
      }
    }

    return error.localizedDescription
  }

  private func updateAssistantMessage(
    id: UUID,
    text: String,
    state: ChatMessageState
  ) {
    guard let index = messages.firstIndex(where: { $0.id == id }) else { return }

    messages[index].text = text
    messages[index].state = state
  }
}
