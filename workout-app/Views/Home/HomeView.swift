import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showingSettings = false
    @State private var isDeleting = false
    @Environment(\.modelContext) private var modelContext
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                }
                
                Spacer()
                
                 NavigationLink("New Routine") {
                     // routine creation view
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
