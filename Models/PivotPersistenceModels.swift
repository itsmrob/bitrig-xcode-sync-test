import Foundation

struct PivotDocument: Codable {
  var id: String
  var projectId: String
  var pivots: [PersistedPivot]
  var createdAt: String
  var updatedAt: String

  enum CodingKeys: String, CodingKey {
    case id = "_id"
    case projectId
    case pivots
    case createdAt
    case updatedAt
  }
}

struct PersistedPivot: Codable {
  var id: String
  var title: String
  var description: String
  var currentCategory: String
  var optionCategory: String
  var currentItem: String
  var optionItem: String
  var impact: String
  var effort: String
  var notes: String
  var createdAt: String
  var updatedAt: String
}

struct PivotNotesEnvelope: Codable {
  var userNotes: String
  var currentItems: [PersistedPivotSnapshot]
  var optionItems: [PersistedPivotSnapshot]
}

struct PersistedPivotSnapshot: Codable {
  var id: String
  var title: String
  var groupType: String
  var categoryId: String
  var categoryName: String
}
