import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            List {
                Text("App language")

                Section {
                    Button("Delete All Data", role: .destructive) {
                        Task {
                            await handleDeleteAllData()
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close", systemImage: "xmark") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func handleDeleteAllData() async {
        isDeleting = true
        defer { isDeleting = false }

        do {
            try DataManager.shared.deleteAllData(from: modelContext)
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}

