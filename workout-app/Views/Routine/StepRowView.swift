import SwiftUI

struct StepRowView: View {
    let stepName: String
    let stepDetail: String
    let onChangeType: () -> Void
    let onChangeAmount: () -> Void
    let onDelete: () -> Void
    let onRemoveFromRepeat: (() -> Void)?

    // Render flat when used inside a RepeatGroupView
    var embedded: Bool = false

    // Extract row content so we can reuse it with two styles (standalone vs embedded)
    private var rowContent: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stepName)
                    .font(.title3)
                    .foregroundColor(.primary)
                Text(stepDetail)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }

            Spacer()
            
            Menu {
                Button { onChangeType() } label: {
                    Label("Change type", systemImage: "figure.strengthtraining.functional")
                }
                Button { onChangeAmount() } label: {
                    Label("Change amount", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                }
                if embedded, let onRemoveFromRepeat = onRemoveFromRepeat {
                    Button { onRemoveFromRepeat() } label: {
                        Label("Remove from repeat", systemImage: "arrow.up.right.square")
                    }
                }
                Button(role: .destructive) { onDelete() } label: {
                    Label("Remove step", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .padding(12)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(Circle())
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    var body: some View {
        if embedded {
            rowContent
                .padding(.vertical, 15)
                .padding(.horizontal, 17)
        } else {
            rowContent
                .padding(.vertical, 15)
                .padding(.horizontal, 17)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .cornerRadius(20)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
    }
}

#Preview("Step Row Variants") {
    List {
        StepRowView(
            stepName: "Alternating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Altenating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Barbell Bech Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Plank",
            stepDetail: "10 reps",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Alternating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )

        StepRowView(
            stepName: "Alternating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Altenating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Barbell Bech Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
        StepRowView(
            stepName: "Plank",
            stepDetail: "10 reps",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {},
            onRemoveFromRepeat: nil
        )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(Color(UIColor.systemGroupedBackground))
}
