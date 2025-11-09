import SwiftUI

struct RepeatGroupView: View {
    let repeatCount: Int
    let steps: [RoutineEditView.StepSummary]
    let repeatId: UUID
    let onStepDrag: (RoutineEditView.StepSummary) -> NSItemProvider
    let onStepDrop: (RoutineEditView.StepSummary) -> any DropDelegate
    let onStepDelete: (UUID) -> Void
    let onGroupDelete: () -> Void
    let onGroupDrop: () -> any DropDelegate
    let onRemoveFromRepeat: (UUID) -> Void
    let isDraggingStep: Bool

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
                    Button { /* change repeat count */ } label: {
                        Label("Change repeat count", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    Button(role: .destructive) { onGroupDelete() } label: {
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

            // Steps inside repeat
            ForEach(steps) { step in
                Divider()
                    .padding(.leading, 17)

                StepRowView(
                    stepName: step.name,
                    stepDetail: step.detail,
                    onChangeType: { },
                    onChangeAmount: { },
                    onDelete: { onStepDelete(step.id) },
                    onRemoveFromRepeat: { onRemoveFromRepeat(step.id) },
                    embedded: true
                )
                .onDrag {
                    onStepDrag(step)
                }
                .onDrop(
                    of: [.text],
                    delegate: onStepDrop(step)
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isDraggingStep ? Color.blue.opacity(0.1) : Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isDraggingStep ? Color.blue : Color.clear, lineWidth: 2)
        )
        .cornerRadius(20)
        .onDrop(
            of: [.text],
            delegate: onGroupDrop()
        )
    }
}