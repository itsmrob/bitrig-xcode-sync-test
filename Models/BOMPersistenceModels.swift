import Foundation

struct BOMDocument: Codable {
  var projectName: String
  var lastAIRequest: String
  var current: BOMCategoryItems
  var options: BOMCategoryItems

  var isEmpty: Bool {
    current.isEmpty && options.isEmpty
  }
}
