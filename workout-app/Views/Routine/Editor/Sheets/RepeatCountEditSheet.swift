import SwiftUI

struct RepeatCountEditSheet: View {
    @Binding var sheetDetent: PresentationDetent
    let currentCount: Int
    let onSave: (Int) -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedCount: Int

    private let options = Array(2...50)

    init(
        sheetDetent: Binding<PresentationDetent>,
        currentCount: Int,
        onSave: @escaping (Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _sheetDetent = sheetDetent
        self.currentCount = currentCount
        self.onSave = onSave
        self.onCancel = onCancel
        _selectedCount = State(initialValue: currentCount)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Repeat count", selection: $selectedCount) {
                    ForEach(options, id: \.self) { count in
                        Text("\(count)x").tag(count)
                    }
                }
                .pickerStyle(.wheel)
                HStack {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button("Save") {
                        onSave(selectedCount)
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationTitle("Repeat Count")
        }
    }
}
