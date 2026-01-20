import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            Tab("Home", systemImage: "figure.cooldown") {
                HomeView()
            }
            Tab("Activity", systemImage: "chevron.up.forward.2") {
                ActivityView()
            }
            Tab(role: .search) {
                ExerciseSearchView()
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
