import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      InputsView()
        .tabItem {
          Label("Inputs", systemImage: "square.and.pencil")
        }

      CreatePivotView()
        .tabItem {
          Label("Create Pivot", systemImage: "arrow.triangle.branch")
        }

      PivotsView()
        .tabItem {
          Label("Pivots", systemImage: "square.stack.3d.up")
        }
    }
  }
}
