import SwiftUI

struct TimedPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var seconds: Int
    let onNext: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            TimedPicker(
                seconds: $seconds,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onPrimary: {
                    onNext()
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Timed")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    TimedPickerSheet(
        seconds: .constant(60),
        onNext: {},
        onCancel: {}
    )
}
