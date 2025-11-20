import SwiftUI

struct RepeatGroupView: View {
    let repeatCount: Int
    let items: [RepeatItem]
    let repeatId: UUID
    let onItemDrag: (RepeatItem) -> NSItemProvider
    let onItemDrop: (RepeatItem) -> any DropDelegate
    let onItemDelete: (UUID) -> Void
    let onItemChangeType: (UUID) -> Void
    let onItemChangeAmount: (UUID) -> Void
    let onGroupChangeCount: () -> Void
    let onGroupDelete: () -> Void
    let onGroupDrop: () -> any DropDelegate
    let onRemoveFromRepeat: (UUID) -> Void
    let isHighlighted: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "repeat")
                    .foregroundColor(.secondary)
                Text("Repeat")
                    .font(.title3)
                    .foregroundColor(.primary)
                Text("\(repeatCount) times")
                    .font(.callout)
                    .foregroundColor(.secondary)

                Spacer()

                Menu {
                    Button {
                        onGroupChangeCount()
                    } label: {
                        Label(
                            "Change repeat count",
                            systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    Button(role: .destructive) {
                        onGroupDelete()
                    } label: {
                        Label("Remove repeat", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .padding(12)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 17)

            // Items inside repeat
            ForEach(items) { item in
                Divider()
                    .padding(.leading, 17)

                StepRowView(
                    stepName: item.displayName,
                    stepMode: repeatItemToStepMode(item),
                    onChangeType: { onItemChangeType(item.id) },
                    onChangeAmount: { onItemChangeAmount(item.id) },
                    onDelete: { onItemDelete(item.id) },
                    onRemoveFromRepeat: { onRemoveFromRepeat(item.id) },
                    embedded: true
                )
                .onDrag {
                    onItemDrag(item)
                }
                .onDrop(
                    of: [.text],
                    delegate: onItemDrop(item)
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isHighlighted
                        ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isHighlighted ? Color.blue : Color.clear, lineWidth: 2)
        )
        .cornerRadius(20)
        .onDrop(
            of: [.text],
            delegate: onGroupDrop()
        )
    }

    // Convert RepeatItem to StepMode for StepRowView compatibility
    private func repeatItemToStepMode(_ item: RepeatItem) -> StepMode {
        switch item {
        case .exercise(_, _, let mode):
            switch mode {
            case .timed(let seconds):
                return .exerciseTimed(seconds: seconds)
            case .reps(let count):
                return .exerciseReps(count: count)
            case .open:
                return .exerciseOpen
            }
        case .rest(_, let mode):
            switch mode {
            case .timed(let seconds):
                return .restTimed(seconds: seconds)
            case .open:
                return .restOpen
            }
        }
    }
}
