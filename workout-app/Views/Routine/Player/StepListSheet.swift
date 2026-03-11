import SwiftData
import SwiftUI

struct StepListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]

    let steps: [PlayableStep]
    let currentStepIndex: Int
    let currentStepProgress: Double

    var body: some View {
        NavigationStack {
            List(Array(steps.enumerated()), id: \.element.id) { index, step in
                StepListRow(
                    index: index,
                    step: step,
                    isCurrent: index == currentStepIndex,
                    progress: index == currentStepIndex ? (step.isTimed ? currentStepProgress : 1) : 0,
                    name: stepName(for: step),
                    detail: stepDetail(for: step)
                )
            }
            .listRowSpacing(5)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Helpers

    private func stepName(for step: PlayableStep) -> String {
        if step.isRest {
            return "Rest"
        }
        guard let exerciseId = step.exerciseId else {
            return "Exercise"
        }
        return exercises.first { $0.id == exerciseId }?.getName() ?? "Exercise"
    }

    private func stepDetail(for step: PlayableStep) -> String {
        switch step.mode {
        case .exerciseTimed(let seconds):
            return "Timed · \(formattedDuration(seconds))"
        case .restTimed(let seconds):
            return "Timed · \(formattedDuration(seconds))"
        case .exerciseReps(let count):
            return "\(count) reps"
        case .exerciseOpen:
            return "Open"
        case .restOpen:
            return "Open"
        }
    }

    private func formattedDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s > 0 ? "\(m)m \(s)s" : "\(m)m"
        }
        return "\(seconds)s"
    }
}

// MARK: - Step List Row

private struct StepListRow: View {
    let index: Int
    let step: PlayableStep
    let isCurrent: Bool
    let progress: Double
    let name: String
    let detail: String

    var body: some View {
        HStack {
            Text("\(index + 1)")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .leading)

            VStack(alignment: .leading, spacing: 5) {
                Text(name)
                    .font(.body)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .listRowBackground(
            ProgressFillBackground(progress: progress)
        )
    }
}

// MARK: - Progress Fill Background

private struct ProgressFillBackground: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            Color.secondary.opacity(0.2)
                .frame(width: geometry.size.width * max(0, min(1, progress)))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    let steps = [
        PlayableStep(exerciseId: nil, type: .rest, mode: .restTimed(seconds: 3)),
        PlayableStep(exerciseId: "pushups", type: .exercise, mode: .exerciseTimed(seconds: 30)),
        PlayableStep(exerciseId: nil, type: .rest, mode: .restTimed(seconds: 15)),
        PlayableStep(exerciseId: "squats", type: .exercise, mode: .exerciseReps(count: 15)),
    ]

    StepListSheet(steps: steps, currentStepIndex: 1, currentStepProgress: 0.5)
        .modelContainer(for: [Exercise.self])
}
