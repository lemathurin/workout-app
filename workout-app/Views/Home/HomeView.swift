import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showingSettings = false
    @State private var showingNewRoutineModal = false
    @State private var newRoutineName = ""
    @State private var isDeleting = false
    @State private var navigateToRoutineEdit = false
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dataManager = DataManager.shared
    @Query private var routines: [Routine]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                }
                
                Spacer()
                
                Button("New Routine") {
                    showingNewRoutineModal = true
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
        .sheet(isPresented: $showingSettings) { SettingsView() }
        .sheet(isPresented: $showingNewRoutineModal) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Create New Routine")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    TextField("Routine Name", text: $newRoutineName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingNewRoutineModal = false
                            newRoutineName = ""
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Continue") {
                            showingNewRoutineModal = false
                            newRoutineName = ""
                            navigateToRoutineEdit = true
                        }
                        .disabled(newRoutineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToRoutineEdit) {
            RoutineEditView() // Navigate to RoutineEditView
        }
    }
    
    private func handleDeleteAllData() async {
        isDeleting = true
        
        do {
            try dataManager.deleteAllData(from: modelContext)
            // Optionally reload initial data
            // await dataManager.reloadInitialData(from: modelContext)
        } catch {
            print("Failed to delete data: \(error)")
        }
        
        isDeleting = false
    }
}

#Preview {
    HomeView()
}
