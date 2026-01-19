import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var showingSettings = false
    @State private var isDeleting = false
    @State private var navigationPath: [String] = []
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dataManager = DataManager.shared
    @Query private var routines: [Routine]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }

                    Spacer()

                    NavigationLink(value: "newRoutine") {
                        Text("New Routine")
                    }
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)

                ScrollView {
                    VStack(spacing: 20) {
                        Text("Ready for some exercise?")
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)

                        // Routines Section
                        if !routines.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Your Routines")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(.horizontal)

                                LazyVStack(spacing: 12) {
                                    ForEach(routines) { routine in
                                        RoutineCard(routine: routine)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        // Delete all data button
                        Button("Delete All Data") {
                            Task {
                                await handleDeleteAllData()
                            }
                        }
                        .disabled(isDeleting)
                    }
                    .padding(.vertical)
                }
            }
            .navigationDestination(for: String.self) { value in
                if value == "newRoutine" {
                    RoutineEditView()
                }
            }
        }
        .sheet(isPresented: $showingSettings) { SettingsView() }
    }

    private func handleDeleteAllData() async {
        isDeleting = true

        do {
            try dataManager.deleteAllData(from: modelContext)
        } catch {
            print("Failed to delete data: \(error)")
        }

        isDeleting = false
    }
}

#Preview {
    HomeView()
}
