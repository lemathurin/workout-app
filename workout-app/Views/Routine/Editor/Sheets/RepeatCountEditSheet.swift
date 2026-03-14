import SwiftUI

struct RepeatCountEditSheet: View {
    let currentCount: Int
    let onSave: (Int) -> Void
    let onCancel: () -> Void

    @State private var selectedCount: Int

    init(
        currentCount: Int,
        onSave: @escaping (Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.currentCount = currentCount
        self.onSave = onSave
        self.onCancel = onCancel
        _selectedCount = State(initialValue: currentCount)
    }

    var body: some View {
        DynamicSheet(animation: .smooth(duration: 0.25, extraBounce: 0)) {
            VStack(spacing: 12) {
                Text("Repeat Count")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                RepeatCountPicker(
                    count: $selectedCount,
                    primaryLabel: "Save",
                    secondaryLabel: "Cancel",
                    onPrimary: { onSave(selectedCount) },
                    onSecondary: onCancel
                )
            }
            .padding([.horizontal, .top], 20)
        }
    }
}
