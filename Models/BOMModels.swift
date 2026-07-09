import Foundation
import SwiftUI

enum GroupType: String, CaseIterable, Identifiable {
  case current
  case options

  var id: Self { self }

  var title: String {
    switch self {
    case .current:
      return "Current"
    case .options:
      return "Options"
    }
  }

  var itemLabel: String {
    switch self {
    case .current:
      return "Current item"
    case .options:
      return "Option item"
    }
  }
}

enum BOMCategoryID: String, CaseIterable, Identifiable {
  case production
  case offering
  case delivery
  case market
  case businessModel

  var id: String { rawValue }
}

struct Category: Identifiable {
  var id: String { key.rawValue }
  var key: BOMCategoryID
  var name: String
  var color: Color
  var symbol: String

  static let all: [Category] = [
    Category(key: .production, name: "Production", color: .teal, symbol: "gearshape.2.fill"),
    Category(key: .offering, name: "Offering", color: .red, symbol: "tag.fill"),
    Category(key: .delivery, name: "Delivery", color: .orange, symbol: "shippingbox.fill"),
    Category(key: .market, name: "Market", color: .green, symbol: "chart.line.uptrend.xyaxis"),
    Category(key: .businessModel, name: "Business Model", color: .blue, symbol: "briefcase.fill")
  ]
}

struct BOMItem: Identifiable, Equatable {
  let id: UUID
  var title: String
  let groupType: GroupType
  let categoryId: String
  let createdAt: Date
}

struct BOMItemSnapshot: Identifiable, Equatable {
  let id: UUID
  let title: String
  let groupType: GroupType
  let categoryId: String
  let categoryName: String
}

struct Pivot: Identifiable, Equatable {
  let id: UUID
  var title: String
  var currentItems: [BOMItemSnapshot]
  var optionItems: [BOMItemSnapshot]
  let createdAt: Date
  var pivotDescription = ""
  var currentCategory = ""
  var optionCategory = ""
  var currentItem = ""
  var optionItem = ""
  var impact = ""
  var effort = ""
  var notes = ""
  var updatedAt = Date()
}

struct CategoryItemGroup: Identifiable {
  var id: String { category.id }
  var category: Category
  var items: [BOMItem]
}

struct PivotSnapshotGroup: Identifiable {
  var id: String { category.id }
  var category: Category
  var items: [BOMItemSnapshot]
}

enum BOMValidationError: LocalizedError {
  case emptyItemName
  case duplicateItem
  case emptyPivotSelection
  case emptyPivotTitle

  var errorDescription: String? {
    switch self {
    case .emptyItemName:
      return "Enter a name before saving."
    case .duplicateItem:
      return "That item already exists in this category."
    case .emptyPivotSelection:
      return "Select at least one Current item and one Option item."
    case .emptyPivotTitle:
      return "Enter a pivot name."
    }
  }
}
