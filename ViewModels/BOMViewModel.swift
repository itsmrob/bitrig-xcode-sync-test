import Combine
import Foundation

@MainActor
final class BOMViewModel: ObservableObject {
  @Published var items: [BOMItem] = []
  @Published var pivots: [Pivot] = []
  @Published var selectedCurrentItemIds: Set<UUID> = []
  @Published var selectedOptionItemIds: Set<UUID> = []
  @Published var hasUnsavedChanges = false
  @Published var isSaving = false
  @Published var saveErrorMessage: String?

  let categories = Category.all

  private let persistenceService: BOMPersistenceService
  private var hasLoadedProject = false
  private var changeRevision = 0

  init(persistenceService: BOMPersistenceService = BOMPersistenceService()) {
    self.persistenceService = persistenceService
  }

  var hasItems: Bool {
    !items.isEmpty
  }

  func itemCount(for category: Category, groupType: GroupType) -> Int {
    items
      .filter { $0.categoryId == category.id && $0.groupType == groupType }
      .count
  }

  func item(with id: UUID) -> BOMItem? {
    items.first { $0.id == id }
  }

  func pivot(with id: UUID) -> Pivot? {
    pivots.first { $0.id == id }
  }

  func items(for category: Category, groupType: GroupType, searchText: String = "") -> [BOMItem] {
    let filteredItems = items.filter {
      $0.categoryId == category.id &&
      $0.groupType == groupType &&
      (searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText))
    }

    return filteredItems.sorted { lhs, rhs in
      if lhs.createdAt == rhs.createdAt {
        return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
      }
      return lhs.createdAt < rhs.createdAt
    }
  }

  func groupedItems(for groupType: GroupType) -> [CategoryItemGroup] {
    categories.compactMap { category in
      let categoryItems = items(for: category, groupType: groupType)
      guard !categoryItems.isEmpty else { return nil }
      return CategoryItemGroup(category: category, items: categoryItems)
    }
  }

  func groupedSnapshots(for pivot: Pivot, groupType: GroupType) -> [PivotSnapshotGroup] {
    let snapshots = groupType == .current ? pivot.currentItems : pivot.optionItems

    return categories.compactMap { category in
      let categorySnapshots = snapshots.filter { $0.categoryId == category.id }
      guard !categorySnapshots.isEmpty else { return nil }
      return PivotSnapshotGroup(category: category, items: categorySnapshots)
    }
  }

  func filteredPivots(searchText: String) -> [Pivot] {
    let filtered = pivots.filter { pivot in
      searchText.isEmpty ||
      pivot.title.localizedCaseInsensitiveContains(searchText) ||
      previewSummary(for: pivot).localizedCaseInsensitiveContains(searchText)
    }

    return filtered.sorted { $0.createdAt > $1.createdAt }
  }

  func addItem(title: String, groupType: GroupType, categoryId: BOMCategoryID) throws {
    let trimmedTitle = normalizedTitle(title)
    try validateItemName(
      trimmedTitle,
      groupType: groupType,
      categoryId: categoryId.rawValue,
      excluding: nil
    )

    items.append(
      BOMItem(
        id: UUID(),
        title: trimmedTitle,
        groupType: groupType,
        categoryId: categoryId.rawValue,
        createdAt: Date()
      )
    )

    registerMutation()
  }

  func updateItem(
    id: UUID,
    title: String,
    groupType: GroupType,
    categoryId: BOMCategoryID
  ) throws {
    guard let index = items.firstIndex(where: { $0.id == id }) else { return }

    let trimmedTitle = normalizedTitle(title)
    try validateItemName(
      trimmedTitle,
      groupType: groupType,
      categoryId: categoryId.rawValue,
      excluding: id
    )

    let originalItem = items[index]
    items[index] = BOMItem(
      id: originalItem.id,
      title: trimmedTitle,
      groupType: groupType,
      categoryId: categoryId.rawValue,
      createdAt: originalItem.createdAt
    )

    selectedCurrentItemIds.remove(id)
    selectedOptionItemIds.remove(id)
    registerMutation()
  }

  func deleteItem(id: UUID) {
    items.removeAll { $0.id == id }
    selectedCurrentItemIds.remove(id)
    selectedOptionItemIds.remove(id)
    registerMutation()
  }

  func toggleSelection(for item: BOMItem) {
    switch item.groupType {
    case .current:
      if selectedCurrentItemIds.contains(item.id) {
        selectedCurrentItemIds.remove(item.id)
      } else {
        selectedCurrentItemIds.insert(item.id)
      }
    case .options:
      if selectedOptionItemIds.contains(item.id) {
        selectedOptionItemIds.remove(item.id)
      } else {
        selectedOptionItemIds.insert(item.id)
      }
    }
  }

  func isSelected(_ item: BOMItem) -> Bool {
    switch item.groupType {
    case .current:
      return selectedCurrentItemIds.contains(item.id)
    case .options:
      return selectedOptionItemIds.contains(item.id)
    }
  }

  func selectedCount(for category: Category, groupType: GroupType) -> Int {
    let relevantIDs = groupType == .current ? selectedCurrentItemIds : selectedOptionItemIds
    return items.filter { $0.categoryId == category.id && relevantIDs.contains($0.id) }.count
  }

  var canCreatePivot: Bool {
    !selectedCurrentItemIds.isEmpty && !selectedOptionItemIds.isEmpty
  }

  @discardableResult
  func createPivot() throws -> Pivot {
    let currentItems = items.filter { selectedCurrentItemIds.contains($0.id) }
    let optionItems = items.filter { selectedOptionItemIds.contains($0.id) }

    guard !currentItems.isEmpty, !optionItems.isEmpty else {
      throw BOMValidationError.emptyPivotSelection
    }

    let pivot = Pivot(
      id: UUID(),
      title: "Pivot \(pivots.count + 1)",
      currentItems: currentItems.map(snapshot(for:)),
      optionItems: optionItems.map(snapshot(for:)),
      createdAt: Date()
    )

    pivots.insert(pivot, at: 0)
    clearSelections()
    return pivot
  }

  func clearSelections() {
    selectedCurrentItemIds.removeAll()
    selectedOptionItemIds.removeAll()
  }

  func renamePivot(id: UUID, title: String) throws {
    let trimmedTitle = normalizedTitle(title)
    guard !trimmedTitle.isEmpty else {
      throw BOMValidationError.emptyPivotTitle
    }

    guard let index = pivots.firstIndex(where: { $0.id == id }) else { return }
    pivots[index].title = trimmedTitle
  }

  func deletePivot(id: UUID) {
    pivots.removeAll { $0.id == id }
  }

  @discardableResult
  func removeSnapshot(snapshotID: UUID, groupType: GroupType, from pivotID: UUID) -> Bool {
    guard let index = pivots.firstIndex(where: { $0.id == pivotID }) else { return false }

    switch groupType {
    case .current:
      pivots[index].currentItems.removeAll { $0.id == snapshotID }
    case .options:
      pivots[index].optionItems.removeAll { $0.id == snapshotID }
    }

    return pivots[index].currentItems.isEmpty && pivots[index].optionItems.isEmpty
  }

  func previewSummary(for pivot: Pivot) -> String {
    let names = (pivot.currentItems + pivot.optionItems)
      .map(\.title)
      .prefix(2)

    let summary = names.joined(separator: " and ")
    if summary.isEmpty {
      return "No items left in this pivot."
    }

    if pivot.currentItems.count + pivot.optionItems.count > 2 {
      return "Through \(summary) and more…"
    }

    return "Through \(summary)…"
  }

  func detailSummary(for pivot: Pivot) -> String {
    let currentNames = pivot.currentItems.map(\.title)
    let optionNames = pivot.optionItems.map(\.title)

    if currentNames.isEmpty && optionNames.isEmpty {
      return "This pivot no longer contains any items."
    }

    let currentText = joinedPhrase(for: currentNames)
    let optionText = joinedPhrase(for: optionNames)

    switch (currentText.isEmpty, optionText.isEmpty) {
    case (false, false):
      return "Through \(currentText), you can explore \(optionText)."
    case (false, true):
      return "This pivot currently focuses on \(currentText)."
    case (true, false):
      return "This pivot explores \(optionText)."
    case (true, true):
      return "This pivot no longer contains any items."
    }
  }

  func selectionSummaryText() -> String {
    "\(selectedCurrentItemIds.count) Current · \(selectedOptionItemIds.count) Options selected"
  }

  func replaceItems(with autofill: BOMAutofillResponse) {
    clearSelections()
    items = generatedItems(from: autofill)
    registerMutation()
  }

  func loadProjectIfNeeded() async {
    guard !hasLoadedProject else { return }
    hasLoadedProject = true

    do {
      if let document = try await persistenceService.loadBOM() {
        applyLoadedDocument(document)
      } else {
        markClean()
      }
    } catch {
      markClean()
    }
  }

  func saveProject() async -> Bool {
    guard !isSaving else { return false }

    isSaving = true
    saveErrorMessage = nil
    let revisionAtSaveStart = changeRevision
    let document = makeDocument()

    defer {
      isSaving = false
    }

    do {
      // Persist the full BOM document so the server always has a complete snapshot.
      try await persistenceService.saveBOM(document)

      if changeRevision == revisionAtSaveStart {
        markClean()
      } else {
        saveErrorMessage = nil
      }

      return true
    } catch {
      saveErrorMessage = "Could not save changes."
      return false
    }
  }

  private func category(for id: String) -> Category? {
    categories.first { $0.id == id }
  }

  private func applyLoadedDocument(_ document: BOMDocument) {
    clearSelections()
    items = generatedItems(from: document)
    markClean()
  }

  private func generatedItems(from autofill: BOMAutofillResponse) -> [BOMItem] {
    generatedItems(current: autofill.current, options: autofill.options)
  }

  private func generatedItems(from document: BOMDocument) -> [BOMItem] {
    generatedItems(current: document.current, options: document.options)
  }

  private func generatedItems(
    current: BOMCategoryItems,
    options: BOMCategoryItems
  ) -> [BOMItem] {
    var generatedItems: [BOMItem] = []
    let baseDate = Date()
    var offset = 0

    for groupType in GroupType.allCases {
      for categoryID in BOMCategoryID.allCases {
        let sourceItems = groupType == .current
          ? current.items(for: categoryID)
          : options.items(for: categoryID)

        for title in sanitizedTitles(from: sourceItems) {
          generatedItems.append(
            BOMItem(
              id: UUID(),
              title: title,
              groupType: groupType,
              categoryId: categoryID.rawValue,
              createdAt: baseDate.addingTimeInterval(TimeInterval(offset))
            )
          )
          offset += 1
        }
      }
    }

    return generatedItems
  }

  private func makeDocument() -> BOMDocument {
    BOMDocument(
      current: makeCategoryItems(for: .current),
      options: makeCategoryItems(for: .options)
    )
  }

  private func makeCategoryItems(for groupType: GroupType) -> BOMCategoryItems {
    BOMCategoryItems(
      production: titles(for: .production, groupType: groupType),
      offering: titles(for: .offering, groupType: groupType),
      delivery: titles(for: .delivery, groupType: groupType),
      market: titles(for: .market, groupType: groupType),
      businessModel: titles(for: .businessModel, groupType: groupType)
    )
  }

  private func titles(for categoryID: BOMCategoryID, groupType: GroupType) -> [String] {
    let category = categories.first { $0.key == categoryID }
    guard let category else { return [] }
    return items(for: category, groupType: groupType).map(\.title)
  }

  private func snapshot(for item: BOMItem) -> BOMItemSnapshot {
    let itemCategory = category(for: item.categoryId)

    return BOMItemSnapshot(
      id: item.id,
      title: item.title,
      groupType: item.groupType,
      categoryId: item.categoryId,
      categoryName: itemCategory?.name ?? "Category"
    )
  }

  private func validateItemName(
    _ title: String,
    groupType: GroupType,
    categoryId: String,
    excluding itemID: UUID?
  ) throws {
    guard !title.isEmpty else {
      throw BOMValidationError.emptyItemName
    }

    let duplicateExists = items.contains { item in
      item.id != itemID &&
      item.groupType == groupType &&
      item.categoryId == categoryId &&
      item.title.compare(title, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }

    if duplicateExists {
      throw BOMValidationError.duplicateItem
    }
  }

  private func normalizedTitle(_ title: String) -> String {
    title.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func sanitizedTitles(from titles: [String]) -> [String] {
    var seen = Set<String>()

    return titles.compactMap { rawTitle in
      let trimmedTitle = normalizedTitle(rawTitle)
      guard !trimmedTitle.isEmpty else { return nil }

      let lookupKey = trimmedTitle.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
      guard seen.insert(lookupKey).inserted else { return nil }

      return trimmedTitle
    }
  }

  private func joinedPhrase(for names: [String]) -> String {
    switch names.count {
    case 0:
      return ""
    case 1:
      return names[0]
    case 2:
      return "\(names[0]) and \(names[1])"
    default:
      return "\(names[0]), \(names[1]), and \(names[2])"
    }
  }

  private func registerMutation() {
    changeRevision += 1
    hasUnsavedChanges = true
    saveErrorMessage = nil
  }

  private func markClean() {
    hasUnsavedChanges = false
    saveErrorMessage = nil
  }
}
