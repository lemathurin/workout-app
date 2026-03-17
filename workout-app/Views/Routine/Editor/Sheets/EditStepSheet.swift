import SwiftUI

enum StepEditAction { case changeType, changeAmount, delete }

struct EditStepSheet: View {
    let stepName: String
    let stepMode: StepMode
    let action: StepEditAction
    let onUpdateSummary: (StepMode) -> Void
    let onDelete: () -> Void
    let onCancel: () -> Void

    @State private var exerciseModeSelection: ExerciseMode?
    @State private var restModeSelection: RestMode?
    @State private var timerSeconds: Int = 60
    @State private var repsCount: Int = 10
    @State private var showAmountPicker: Bool

    init(
        stepName: String,
        stepMode: StepMode,
        action: StepEditAction,
        onUpdateSummary: @escaping (StepMode) -> Void,
        onDelete: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.stepName = stepName
        self.stepMode = stepMode
        self.action = action
        self.onUpdateSummary = onUpdateSummary
        self.onDelete = onDelete
        self.onCancel = onCancel

        let (exerciseMode, restMode, seconds, reps) = Self.extractFromStepMode(stepMode)
        _exerciseModeSelection = State(initialValue: exerciseMode)
        _restModeSelection = State(initialValue: restMode)
        _timerSeconds = State(initialValue: seconds)
        _repsCount = State(initialValue: reps)
        _showAmountPicker = State(initialValue: action == .changeAmount)
    }

    var body: some View {
        DynamicSheet(animation: .smooth(duration: 0.25, extraBounce: 0)) {
            VStack(spacing: 18) {
                HStack {
                    Text(stepName)
                        .font(.title)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                ZStack {
                    switch action {
                    case .delete:
                        deleteContent
                            .transition(.blurReplace(.upUp))
                    case .changeType, .changeAmount:
                        if showAmountPicker {
                            amountContent
                                .transition(.blurReplace(.downUp))
                        } else {
                            typeContent
                                .transition(.blurReplace(.upUp))
                        }
                    }
                }
                .geometryGroup()
            }
            .padding([.horizontal, .top], 20)
        }
    }

    private var isExercise: Bool {
        switch stepMode {
        case .exerciseTimed, .exerciseReps, .exerciseOpen: true
        case .restTimed, .restOpen: false
        }
    }

    // MARK: - Type Selection

    @ViewBuilder
    private var typeContent: some View {
        if isExercise {
            VStack(spacing: 18) {
                BigCardButton(
                    title: "routine.edit.timed",
                    description: "routine.edit.timed.description"
                ) {
                    exerciseModeSelection = .timed
                    withAnimation(.smooth(duration: 0.25)) { showAmountPicker = true }
                }

                HStack(spacing: 12) {
                    BigCardButton(
                        title: "routine.edit.repetitions",
                        description: "routine.edit.repetitions.description"
                    ) {
                        exerciseModeSelection = .reps
                        withAnimation(.smooth(duration: 0.25)) { showAmountPicker = true }
                    }

                    BigCardButton(
                        title: "routine.edit.open",
                        description: "routine.edit.open.description"
                    ) {
                        exerciseModeSelection = .open
                        applyAndClose()
                    }
                }

                Button("common.cancel", action: onCancel)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .buttonSizing(.flexible)
                    .foregroundStyle(.primary)
            }
        } else {
            VStack(spacing: 18) {
                HStack(spacing: 12) {
                    BigCardButton(
                        title: "routine.edit.timed",
                        description: "routine.edit.timed.description"
                    ) {
                        restModeSelection = .timed
                        withAnimation(.smooth(duration: 0.25)) { showAmountPicker = true }
                    }

                    BigCardButton(
                        title: "routine.edit.open",
                        description: "routine.edit.open.description"
                    ) {
                        restModeSelection = .open
                        applyAndClose()
                    }
                }

                Button("common.cancel", action: onCancel)
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .buttonSizing(.flexible)
                    .foregroundStyle(.primary)
            }
        }
    }

    // MARK: - Amount Picker

    @ViewBuilder
    private var amountContent: some View {
        if isExercise {
            switch exerciseModeSelection {
            case .timed:
                TimedPicker(
                    seconds: $timerSeconds,
                    primaryLabel: String(localized: "common.save"),
                    secondaryLabel: String(localized: "common.back"),
                    onPrimary: { applyAndClose() },
                    onSecondary: { withAnimation(.smooth(duration: 0.25)) { showAmountPicker = false } }
                )
            case .reps:
                RepsPicker(
                    reps: $repsCount,
                    primaryLabel: String(localized: "common.save"),
                    secondaryLabel: String(localized: "common.back"),
                    onPrimary: { applyAndClose() },
                    onSecondary: { withAnimation(.smooth(duration: 0.25)) { showAmountPicker = false } }
                )
            default:
                Text("No amount to change for open mode.")
                    .foregroundStyle(.secondary)
            }
        } else {
            switch restModeSelection {
            case .timed:
                RestTimedPicker(
                    seconds: $timerSeconds,
                    primaryLabel: String(localized: "common.save"),
                    secondaryLabel: String(localized: "common.back"),
                    onPrimary: { applyAndClose() },
                    onSecondary: { withAnimation(.smooth(duration: 0.25)) { showAmountPicker = false } }
                )
            default:
                Text("No duration to change for open rest.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Delete Confirmation

    private var deleteContent: some View {
        VStack(spacing: 18) {
            Text("routine.edit.deleteStepConfirmation")
                .foregroundStyle(.secondary)

            Button("common.delete", role: .destructive) { onDelete() }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .buttonSizing(.flexible)

            Button("common.cancel", action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .buttonSizing(.flexible)
                .foregroundStyle(.primary)
        }
    }

    // MARK: - Helpers

    private func applyAndClose() {
        let newStepMode: StepMode
        if isExercise {
            switch exerciseModeSelection {
            case .timed: newStepMode = .exerciseTimed(seconds: timerSeconds)
            case .reps: newStepMode = .exerciseReps(count: repsCount)
            case .open, .none: newStepMode = .exerciseOpen
            }
        } else {
            switch restModeSelection {
            case .timed: newStepMode = .restTimed(seconds: timerSeconds)
            case .open, .none: newStepMode = .restOpen
            }
        }
        onUpdateSummary(newStepMode)
    }

    private static func extractFromStepMode(_ stepMode: StepMode) -> (
        exerciseMode: ExerciseMode?, restMode: RestMode?, seconds: Int, reps: Int
    ) {
        switch stepMode {
        case .exerciseTimed(let seconds): (.timed, nil, seconds, 10)
        case .exerciseReps(let count): (.reps, nil, 60, count)
        case .exerciseOpen: (.open, nil, 60, 10)
        case .restTimed(let seconds): (nil, .timed, seconds, 10)
        case .restOpen: (nil, .open, 60, 10)
        }
    }
}
