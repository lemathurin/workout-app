import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            Tab("Home", systemImage: "figure.cooldown") {
                HomeView()
            }
            Tab("Catalog", systemImage: "magazine") {
                CatalogView()
            }
        }
        .task {
        await DataLoader.shared.loadInitialData(modelContext: modelContext)
    }
    }
}

#Preview {
    ContentView()
}
