import SwiftUI

struct MainTabView: View {
  var body: some View {
    TabView {
      InputsView()
        .tabItem {
          Label("Data Inputs from xCode", systemImage: "square.and.pencil")
        }

      CreatePivotView()
        .tabItem {
          Label("Create Pivot from xCode", systemImage: "arrow.triangle.branch")
        }

      PivotsView()
        .tabItem {
          Label("Pivots", systemImage: "square.stack.3d.up")
        }
    }
  }
}
