import Foundation

enum DateFormatters {
  static let itemTimestamp: Date.FormatStyle = .dateTime
    .month(.abbreviated)
    .day()
    .year()
    .hour()
    .minute()

  static let aiPlaygroundTimestamp: Date.FormatStyle = .dateTime
    .month(.abbreviated)
    .day()
    .hour()
    .minute()
}
