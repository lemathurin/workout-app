import SwiftUI

struct RestTimedPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var seconds: Int
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            RestTimedPicker(
                seconds: $seconds,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onPrimary: {
                    onSave()
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Rest (Timed)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RestTimedPickerSheet(
        seconds: .constant(30),
        onSave: {},
        onCancel: {}
    )
}
