import Foundation

@MainActor
final class BOMAutofillViewModel: ObservableObject {
  @Published var prompt = """
  We own a local coffee shop with two locations. Our current operations rely heavily on manual processes, inventory management is inconsistent, and customer wait times are long during peak hours. We want to improve operational efficiency, increase customer satisfaction, expand our product offerings, optimize delivery, reach more customers through digital channels, and create new revenue opportunities.
  """
  @Published var isGenerating = false
  @Published var errorMessage: String?

  private let service: AIService

  init(service: AIService = AIService()) {
    self.service = service
  }

  var canGenerate: Bool {
    !trimmedPrompt.isEmpty && !isGenerating
  }

  // The sheet delegates the full autofill request lifecycle here so the view stays presentation-only.
  @discardableResult
  func generateAutofill(into bomViewModel: BOMViewModel) async -> Bool {
    let submittedPrompt = trimmedPrompt
    guard !submittedPrompt.isEmpty, !isGenerating else {
      if submittedPrompt.isEmpty {
        errorMessage = "Enter a description before generating."
      }
      return false
    }

    isGenerating = true
    errorMessage = nil

    defer {
      isGenerating = false
    }

    do {
      let response = try await service.generateBOMAutofill(prompt: submittedPrompt)
      bomViewModel.replaceItems(with: response)
      prompt = ""
      return true
    } catch {
      errorMessage = formattedErrorMessage(from: error)
      return false
    }
  }

  func resetError() {
    errorMessage = nil
  }

  private var trimmedPrompt: String {
    prompt.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func formattedErrorMessage(from error: Error) -> String {
    if let serviceError = error as? AIServiceError {
      switch serviceError {
      case .invalidResponse, .requestFailed, .decodingFailed, .emptyResult:
        return "Could not generate data. Please check the backend and try again."
      }
    }

    if error is URLError {
      return "Could not generate data. Please check the backend and try again."
    }

    return "Could not generate data. Please check the backend and try again."
  }
}
