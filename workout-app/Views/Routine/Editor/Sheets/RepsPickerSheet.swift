import SwiftUI

struct RepsPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var reps: Int
    let onNext: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            RepsPicker(
                reps: $reps,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onPrimary: {
                    onNext()
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Reps")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RepsPickerSheet(
        reps: .constant(10),
        onNext: {},
        onCancel: {}
    )
}
