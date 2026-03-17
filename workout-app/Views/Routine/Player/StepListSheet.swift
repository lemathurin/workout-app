import SwiftData
import SwiftUI

struct StepListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    @Query private var equipment: [Equipment]

    let steps: [PlayableStep]
    let currentStepIndex: Int
    let currentStepProgress: Double
    var onStepSelected: ((Int) -> Void)?

    var body: some View {
        NavigationStack {
            List(Array(steps.enumerated()), id: \.element.id) { index, step in
                Button {
                    onStepSelected?(index)
                } label: {
                    StepListRow(
                        index: index,
                        step: step,
                        name: stepName(for: step),
                        detail: stepDetail(for: step)
                    )
                }
                .tint(.primary)
                .listRowBackground(
                    ProgressFillBackground(
                        progress: index == currentStepIndex ? (step.isTimed ? currentStepProgress : 1) : 0
                    )
                )
            }
            .listRowSpacing(5)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Helpers

    private func stepName(for step: PlayableStep) -> String {
        if step.isRest {
            return String(localized: "common.rest")
        }
        guard let exerciseId = step.exerciseId else {
            return String(localized: "common.exercise")
        }
        return exercises.first { $0.id == exerciseId }?.getName() ?? String(localized: "common.exercise")
    }

    private func stepDetail(for step: PlayableStep) -> String {
        var parts: [String] = []

        switch step.mode {
        case .exerciseTimed(let seconds), .restTimed(let seconds):
            let duration = Duration.seconds(seconds).formatted(.units(width: .abbreviated))
            parts.append(String(localized: "routine.edit.timed") + " · " + duration)
        case .exerciseReps(let count):
            parts.append(String(localized: "\(count) common.repetitions"))
        case .exerciseOpen, .restOpen:
            parts.append(String(localized: "common.open"))
        }

        if let equipmentName = equipmentName(for: step) {
            parts.append(equipmentName)
        }

        return parts.joined(separator: " · ")
    }

    private func equipmentName(for step: PlayableStep) -> String? {
        guard let exerciseId = step.exerciseId,
              let exercise = exercises.first(where: { $0.id == exerciseId })
        else { return nil }
        guard exercise.equipmentId != "body_only" else { return nil }
        return equipment.first { $0.id == exercise.equipmentId }?
            .translations.first { $0.languageCode == "en" }?.text
    }
}

// MARK: - Step List Row

private struct StepListRow: View {
    let index: Int
    let step: PlayableStep
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
        .modelContainer(for: [Exercise.self, Equipment.self])
}
