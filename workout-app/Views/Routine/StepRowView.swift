import SwiftUI

struct StepRowView: View {
    let stepName: String
    let stepDetail: String
    let onChangeType: () -> Void
    let onChangeAmount: () -> Void
    let onDelete: () -> Void

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
            onDelete: {}
        )
        StepRowView(
            stepName: "Altenating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
        StepRowView(
            stepName: "Barbell Bech Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
        StepRowView(
            stepName: "Plank",
            stepDetail: "10 reps",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
        StepRowView(
            stepName: "Russian Twists",
            stepDetail: "10 reps",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )

        RepeatGroupView(
            times: 5,
            steps: [
                .init(
                    name: "Push ups",
                    detail: "10 reps",
                    onChangeType: {},
                    onChangeAmount: {},
                    onDelete: {}
                ),
                .init(
                    name: "Rest",
                    detail: "open",
                    onChangeType: {},
                    onChangeAmount: {},
                    onDelete: {}
                )
            ]
        )

        StepRowView(
            stepName: "Alternating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
        StepRowView(
            stepName: "Altenating Cable Shoulder Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
        StepRowView(
            stepName: "Barbell Bech Press",
            stepDetail: "30 seconds",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
        StepRowView(
            stepName: "Plank",
            stepDetail: "10 reps",
            onChangeType: {},
            onChangeAmount: {},
            onDelete: {}
        )
    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(Color(UIColor.systemGroupedBackground))
}

struct RepeatGroupView: View {
    struct RepeatStep: Identifiable {
        let id = UUID()
        let name: String
        let detail: String
        let onChangeType: () -> Void
        let onChangeAmount: () -> Void
        let onDelete: () -> Void
    }

    let times: Int
    let steps: [RepeatStep]
    var onDeleteGroup: () -> Void = {}

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(.secondary)
                        Text("Repeat")
                            .font(.title3)
                            .foregroundColor(.primary)
                        Text("\(times) times")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Menu {
                    Button {} label: {
                        Label("Change amount", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    Button(role: .destructive) {
                        onDeleteGroup()
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
            .padding(.vertical, 12)
            .padding(.horizontal, 17)

            Divider()

            ForEach(steps.indices, id: \.self) { idx in
                let s = steps[idx]
                StepRowView(
                    stepName: s.name,
                    stepDetail: s.detail,
                    onChangeType: s.onChangeType,
                    onChangeAmount: s.onChangeAmount,
                    onDelete: s.onDelete,
                    embedded: true
                )
                if idx < steps.count - 1 {
                    Divider()
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .cornerRadius(20)
        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
