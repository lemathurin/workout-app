import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isDeleting = false

    var body: some View {
        NavigationStack {
            List {
                Section("settings.general") {
                    NavigationLink("settings.iCloudSync") {
//
                    }
                    .disabled(true)
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        LabeledContent("settings.language") {
                            Image(systemName: "arrow.up.forward")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                Section("settings.appearance") {
                    NavigationLink("settings.theme") {
//
                    }
                    .disabled(true)
                    NavigationLink("settings.appIcon") {
//
                    }
                    .disabled(true)
                }
                
                Section("settings.about") {
                    NavigationLink("settings.acknowledgements") {
                        AcknowledgementsView()
                    }
                    NavigationLink("settings.aboutMe") {
//
                    }
                    .disabled(true)
                }
                
                Section("settings.legal") {
                    NavigationLink("settings.termsOfUse") {
//
                    }
                    NavigationLink("settings.privacyPolicy") {
//
                    }
                }
                .disabled(true)

                Section("common.danger") {
                    Button("settings.deleteData", role: .destructive) {
                        Task {
                            await handleDeleteAllData()
                        }
                    }
                    .disabled(isDeleting)
                }
            }
            .navigationTitle("settings.title")
            .toolbarTitleDisplayMode(.inline)
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

