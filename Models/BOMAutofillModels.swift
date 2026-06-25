import Foundation

struct BOMAutofillRequest: Encodable {
  var prompt: String
}

struct BOMAutofillResponse: Decodable {
  var current: BOMCategoryItems
  var options: BOMCategoryItems
}

struct BOMCategoryItems: Decodable {
  var production: [String]
  var offering: [String]
  var delivery: [String]
  var market: [String]
  var businessModel: [String]

  func items(for categoryID: BOMCategoryID) -> [String] {
    switch categoryID {
    case .production:
      return production
    case .offering:
      return offering
    case .delivery:
      return delivery
    case .market:
      return market
    case .businessModel:
      return businessModel
    }
  }
}
