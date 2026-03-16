import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            List {
                Text("settings.language")

                Section {
                    Button("settings.deleteData", role: .destructive) {
                        Task {
                            await handleDeleteAllData()
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            .navigationTitle("settings.title")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.close", systemImage: "xmark") {
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
            print("settings.dataDeletionFailure \(error)")
        }
    }
}

#Preview {
    SettingsView()
}

