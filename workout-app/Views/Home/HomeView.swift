import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var showingSettings = false
    @State private var isDeleting = false
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dataManager = DataManager.shared
    @Query private var routines: [Routine]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        showingSettings = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        RoutineEditView()
                    } label: {
                        Label("New Routine", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
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
