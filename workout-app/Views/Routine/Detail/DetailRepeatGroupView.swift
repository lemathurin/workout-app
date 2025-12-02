import SwiftUI

struct DetailRepeatGroupView: View {
    let repeatCount: Int
    let steps: [RoutineStep]
    let exercises: [Exercise]

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
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 17)

            // Steps inside repeat
            if steps.isEmpty {
                VStack(spacing: 0) {
                    Divider()

                    HStack(spacing: 12) {
                        Text("No steps in this repeat")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(.all, 17)
                }
            } else {
                ForEach(steps.sorted(by: { $0.order < $1.order }), id: \.id) { step in
                    Divider()
                        .padding(.leading, 17)

                    DetailStepRowView(
                        stepName: getStepName(for: step),
                        stepMode: routineStepToStepMode(step),
                        embedded: true
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .cornerRadius(20)
    }

    private func getStepName(for step: RoutineStep) -> String {
        switch step.type {
        case .exercise:
            if let exerciseId = step.exerciseId {
                return exercises.first { $0.id == exerciseId }?.getName() ?? "Unknown Exercise"
            }
            return "Unknown Exercise"
        case .rest:
            return "Rest"
        case .repeats:
            return "Repeat"
        }
    }

    private func routineStepToStepMode(_ step: RoutineStep) -> StepMode {
        switch step.type {
        case .exercise:
            // For exercises, check duration and count to determine mode
            if step.duration > 0 {
                return .exerciseTimed(seconds: step.duration)
            } else if let count = step.count, count > 0 {
                return .exerciseReps(count: count)
            } else {
                return .exerciseOpen
            }
        case .rest:
            if step.duration > 0 {
                return .restTimed(seconds: step.duration)
            } else {
                return .restOpen
            }
        case .repeats:
            // This shouldn't be called for repeat types
            return .exerciseOpen
        }
    }
}
