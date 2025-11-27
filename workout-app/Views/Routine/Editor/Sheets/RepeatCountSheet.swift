import SwiftUI

struct RepeatCountSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var count: Int = 2
    let onStartRepeatFlow: (Int) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            RepeatCountPicker(
                count: $count,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onPrimary: {
                    onStartRepeatFlow(count)
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Repeat Count")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RepeatCountSheet(
        onStartRepeatFlow: { _ in },
        onCancel: {}
    )
}
