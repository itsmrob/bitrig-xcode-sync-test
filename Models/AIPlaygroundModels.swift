import Foundation

enum ChatMessageRole: String, Equatable {
  case user
  case assistant
}

enum ChatMessageState: Equatable {
  case sent
  case loading
  case error
}

struct ChatMessage: Identifiable, Equatable {
  let id: UUID
  var role: ChatMessageRole
  var text: String
  var createdAt: Date
  var state: ChatMessageState
}
