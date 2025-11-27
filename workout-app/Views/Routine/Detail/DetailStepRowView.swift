import SwiftUI

struct DetailStepRowView: View {
    let stepName: String
    let stepMode: StepMode

    // Render flat when used inside a repeat group
    var embedded: Bool = false

    private var modeDescription: String {
        switch stepMode {
        case .exerciseTimed(let seconds):
            return "\(seconds) seconds"
        case .exerciseReps(let count):
            return "\(count) reps"
        case .exerciseOpen:
            return "Open"
        case .restTimed(let seconds):
            return "\(seconds) seconds"
        case .restOpen:
            return "Open"
        }
    }

    // Extract row content so we can reuse it with two styles (standalone vs embedded)
    private var rowContent: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stepName)
                    .font(.title3)
                    .foregroundColor(.primary)
                Text(modeDescription)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }

            Spacer()
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
        }
    }
}

#Preview("Detail Step Row Variants") {
    VStack(spacing: 12) {
        DetailStepRowView(
            stepName: "Alternating Cable Shoulder Press",
            stepMode: .exerciseTimed(seconds: 30)
        )
        DetailStepRowView(
            stepName: "Russian Twists",
            stepMode: .exerciseReps(count: 10)
        )
        DetailStepRowView(
            stepName: "Plank",
            stepMode: .exerciseOpen
        )
        DetailStepRowView(
            stepName: "Rest",
            stepMode: .restTimed(seconds: 60)
        )
        DetailStepRowView(
            stepName: "Rest",
            stepMode: .restOpen
        )
    }
    .padding(.horizontal, 16)
    .background(Color(UIColor.systemGroupedBackground))
}
