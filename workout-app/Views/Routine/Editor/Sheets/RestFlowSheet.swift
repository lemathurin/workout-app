import SwiftUI

struct RestFlowSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: RestMode?
    @State private var showRestTimedPicker: Bool = false
    @State private var restSeconds: Int = 30

    let onAddRest: (StepMode) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            RestModeSelector(
                currentMode: selectedMode,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onSelectTimed: {
                    selectedMode = .timed
                    showRestTimedPicker = true
                },
                onSelectOpen: {
                    onAddRest(.restOpen)
                    dismiss()
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Rest Type")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showRestTimedPicker) {
                RestTimedPickerSheet(
                    seconds: $restSeconds,
                    onSave: {
                        onAddRest(.restTimed(seconds: restSeconds))
                        dismiss()
                    },
                    onCancel: {
                        showRestTimedPicker = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
        }
    }
}

#Preview {
    RestFlowSheet(
        onAddRest: { _ in },
        onCancel: {}
    )
}
