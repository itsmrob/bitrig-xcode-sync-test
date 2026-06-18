import Foundation
import Observation

@MainActor
@Observable
final class AIPlaygroundViewModel {
  var prompt = ""
  var latestEntry: AIPlaygroundHistoryEntry?
  var history: [AIPlaygroundHistoryEntry] = []
  var isGenerating = false
  var errorMessage: String?

  private let service: AIService

  init(service: AIService = AIService()) {
    self.service = service
  }

  var canGenerate: Bool {
    !trimmedPrompt.isEmpty && !isGenerating
  }

  func generate() {
    let submittedPrompt = trimmedPrompt
    guard !submittedPrompt.isEmpty, !isGenerating else { return }

    isGenerating = true
    errorMessage = nil

    Task {
      defer { isGenerating = false }

      do {
        // The view model coordinates the request lifecycle so the view only binds to state.
        let response = try await service.generateResponse(for: submittedPrompt)
        let entry = AIPlaygroundHistoryEntry(
          id: UUID(),
          prompt: submittedPrompt,
          response: response,
          createdAt: Date(),
          isError: false
        )

        latestEntry = entry
        history.insert(entry, at: 0)
      } catch {
        let message = formattedErrorMessage(from: error)
        errorMessage = message

        let entry = AIPlaygroundHistoryEntry(
          id: UUID(),
          prompt: submittedPrompt,
          response: message,
          createdAt: Date(),
          isError: true
        )

        latestEntry = entry
        history.insert(entry, at: 0)
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
}
