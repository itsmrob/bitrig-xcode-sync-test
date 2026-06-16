import Foundation

struct AIPlaygroundHistoryEntry: Identifiable, Equatable {
  let id: UUID
  var prompt: String
  var response: String
  var createdAt: Date

  var responsePreview: String {
    let collapsedResponse = response
      .components(separatedBy: .whitespacesAndNewlines)
      .filter { !$0.isEmpty }
      .joined(separator: " ")

    guard collapsedResponse.count > 120 else {
      return collapsedResponse
    }

    return "\(collapsedResponse.prefix(117))…"
  }
}
