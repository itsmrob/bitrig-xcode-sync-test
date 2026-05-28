import SwiftUI

@main
struct BOMLiteMobileApp: App {
  @StateObject private var viewModel = BOMViewModel()

  var body: some Scene {
    WindowGroup {
      MainTabView()
        .environmentObject(viewModel)
    }
  }
}
