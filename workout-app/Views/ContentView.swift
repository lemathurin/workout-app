import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @State var searchText: String = ""

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.getName().localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        TabView {
            Tab("Home", systemImage: "figure.cooldown") {
                HomeView()
            }
            Tab("Catalog", systemImage: "magazine") {
                CatalogView()
            }
            Tab(role: .search) {
                NavigationStack {
                    List(filteredExercises, id: \.id) { exercise in
                        NavigationLink(value: exercise) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(exercise.getName())
                                    .font(.headline)
                                HStack {
                                    Text("Level: \(exercise.levelId)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("Category: \(exercise.categoryId)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .navigationTitle("Exercises")
                    .navigationSubtitle("\(filteredExercises.count) exercises")
                    .navigationDestination(for: Exercise.self) { exercise in
                        ExerciseDetailView(exercise: exercise)
                    }
                }
                .searchable(text: $searchText, prompt: "Search exercises")
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
