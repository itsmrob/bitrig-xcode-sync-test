import Foundation
import Observation

protocol AIPlaygroundGenerating {
  func generateResponse(for prompt: String) async throws -> String
}

struct MockAIPlaygroundGenerator: AIPlaygroundGenerating {
  func generateResponse(for prompt: String) async throws -> String {
    try await Task.sleep(for: .seconds(1.1))

    let shortPrompt = prompt.count > 70 ? "\(prompt.prefix(67))…" : prompt
    return """
    Placeholder response for:
    \(shortPrompt)

    This screen is ready for future AI integration. Replace the mock generator with your OpenAI client, then map the returned text into this response card and history list.
    """
  }
}

@MainActor
@Observable
final class AIPlaygroundViewModel {
  var prompt = ""
  var latestEntry: AIPlaygroundHistoryEntry?
  var history: [AIPlaygroundHistoryEntry] = []
  var isGenerating = false

  private let generator: any AIPlaygroundGenerating

  init(generator: any AIPlaygroundGenerating = MockAIPlaygroundGenerator()) {
    self.generator = generator
  }

  var canGenerate: Bool {
    !trimmedPrompt.isEmpty && !isGenerating
  }

  func generate() {
    let submittedPrompt = trimmedPrompt
    guard !submittedPrompt.isEmpty, !isGenerating else { return }

    isGenerating = true

    Task {
      defer { isGenerating = false }

      do {
        let response = try await generator.generateResponse(for: submittedPrompt)
        let entry = AIPlaygroundHistoryEntry(
          id: UUID(),
          prompt: submittedPrompt,
          response: response,
          createdAt: Date()
        )

        latestEntry = entry
        history.insert(entry, at: 0)
      } catch {
        latestEntry = AIPlaygroundHistoryEntry(
          id: UUID(),
          prompt: submittedPrompt,
          response: "Unable to generate a preview right now. Connect a live AI provider to handle errors and retries.",
          createdAt: Date()
        )
      }
    }
  }

  private var trimmedPrompt: String {
    prompt.trimmingCharacters(in: .whitespacesAndNewlines)
  }
}
