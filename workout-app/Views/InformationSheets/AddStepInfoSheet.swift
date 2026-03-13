import SwiftUI

struct AddStepInfoSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    InfoSection(
                        title: "Exercise",
                        description: "Add a specific movement or activity to your routine. You can set it to be timed, rep-based, or open-ended."
                    )

                    InfoSection(
                        title: "Rest",
                        description: "Insert a pause between exercises to recover. Rests can be timed or open-ended."
                    )

                    InfoSection(
                        title: "Repeat",
                        description: "Loop all the steps above this marker a set number of times. Great for building circuits and supersets."
                    )
                }
                .padding()
            }
            .navigationTitle("Creating a routine")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

private struct InfoSection: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AddStepInfoSheet()
}
