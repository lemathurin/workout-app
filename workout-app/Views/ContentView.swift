import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Tab = .home
    
    enum Tab {
        case home
        case catalog
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                HomeView()
                    .tabItem {
                        Label ("Home",
                               systemImage: "figure.cooldown")
                    }
                    .tag(Tab.home)
                
                CatalogView()
                    .tabItem {
                        Label ("Catalog",
                               systemImage: "magazine")
                    }
                    .tag(Tab.catalog)
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
