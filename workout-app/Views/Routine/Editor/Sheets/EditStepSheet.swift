import SwiftUI

enum StepEditAction { case changeType, changeAmount, delete }

private enum EditStep { case selectType, selectAmount, confirmDelete }

struct EditStepSheet: View {
    @Binding var sheetDetent: PresentationDetent
    let stepName: String
    let stepMode: StepMode
    let action: StepEditAction
    let onUpdateSummary: (StepMode) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var exerciseName: String
    @State private var exerciseModeSelection: ExerciseMode? = .open
    @State private var restModeSelection: RestMode? = .open
    @State private var timerSeconds: Int = 60
    @State private var repsCount: Int = 10
    @State private var editStep: EditStep

    init(
        sheetDetent: Binding<PresentationDetent>,
        stepName: String,
        stepMode: StepMode,
        action: StepEditAction,
        onUpdateSummary: @escaping (StepMode) -> Void,
        onDelete: @escaping () -> Void
    ) {
        _sheetDetent = sheetDetent
        self.stepName = stepName
        self.stepMode = stepMode
        self.action = action
        self.onUpdateSummary = onUpdateSummary
        self.onDelete = onDelete

        _exerciseName = State(initialValue: stepName)

        // Extract mode and amounts from StepMode
        let (exerciseMode, restMode, seconds, reps) = EditStepSheet.extractFromStepMode(stepMode)
        _exerciseModeSelection = State(initialValue: exerciseMode)
        _restModeSelection = State(initialValue: restMode)
        _timerSeconds = State(initialValue: seconds)
        _repsCount = State(initialValue: reps)

        switch action {
        case .changeType:
            _editStep = State(initialValue: .selectType)
        case .changeAmount:
            _editStep = State(initialValue: .selectAmount)
        case .delete:
            _editStep = State(initialValue: .confirmDelete)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch editStep {
                case .selectType:
                    if isExercise {
                        ExerciseModeSelector(
                            currentMode: exerciseModeSelection,
                            primaryLabel: "Save",
                            secondaryLabel: "Cancel",
                            onSelectTimed: {
                                exerciseModeSelection = .timed
                                editStep = .selectAmount
                            },
                            onSelectReps: {
                                exerciseModeSelection = .reps
                                editStep = .selectAmount
                            },
                            onSelectOpen: {
                                exerciseModeSelection = .open
                                applyUpdateAndClose()
                            },
                            onSecondary: { dismiss() }
                        )
                    } else {
                        RestModeSelector(
                            currentMode: restModeSelection,
                            primaryLabel: "Save",
                            secondaryLabel: "Cancel",
                            onSelectTimed: {
                                restModeSelection = .timed
                                editStep = .selectAmount
                            },
                            onSelectOpen: {
                                restModeSelection = .open
                                applyUpdateAndClose()
                            },
                            onSecondary: { dismiss() }
                        )
                    }
                case .selectAmount:
                    if isExercise {
                        switch exerciseModeSelection {
                        case .timed:
                            TimedPicker(
                                seconds: $timerSeconds,
                                primaryLabel: "Save",
                                secondaryLabel: "Cancel",
                                onPrimary: { applyUpdateAndClose() },
                                onSecondary: { dismiss() }
                            )
                        case .reps:
                            RepsPicker(
                                reps: $repsCount,
                                primaryLabel: "Save",
                                secondaryLabel: "Cancel",
                                onPrimary: { applyUpdateAndClose() },
                                onSecondary: { dismiss() }
                            )
                        case .open, .none:
                            InfoView(
                                title: "No amount to change",
                                message: "Open exercises have no duration or reps.",
                                onClose: { dismiss() }
                            )
                        }
                    } else {
                        switch restModeSelection {
                        case .timed:
                            RestTimedPicker(
                                seconds: $timerSeconds,
                                primaryLabel: "Save",
                                secondaryLabel: "Cancel",
                                onPrimary: { applyUpdateAndClose() },
                                onSecondary: { dismiss() }
                            )
                        case .open, .none:
                            InfoView(
                                title: "No duration to change",
                                message: "Open rest has no duration.",
                                onClose: { dismiss() }
                            )
                        }
                    }
                case .confirmDelete:
                    DeleteConfirmView(
                        onCancel: { dismiss() },
                        onDeleteConfirm: {
                            onDelete()
                            dismiss()
                        }
                    )
                }
            }
            .navigationTitle(navigationTitle)
        }
    }

    private var isExercise: Bool {
        switch stepMode {
        case .exerciseTimed, .exerciseReps, .exerciseOpen:
            return true
        case .restTimed, .restOpen:
            return false
        }
    }

    private var navigationTitle: String {
        switch editStep {
        case .selectType, .selectAmount:
            if isExercise {
                if exerciseModeSelection == .open || exerciseModeSelection == .none {
                    return "No amount to change"
                }
            } else {
                if restModeSelection == .open || restModeSelection == .none {
                    return "No duration to change"
                }
            }
            return stepName
        case .confirmDelete:
            return "Delete Step"
        }
    }

    private func applyUpdateAndClose() {
        let newStepMode: StepMode

        if isExercise {
            switch exerciseModeSelection {
            case .timed:
                newStepMode = .exerciseTimed(seconds: timerSeconds)
            case .reps:
                newStepMode = .exerciseReps(count: repsCount)
            case .open, .none:
                newStepMode = .exerciseOpen
            }
        } else {
            switch restModeSelection {
            case .timed:
                newStepMode = .restTimed(seconds: timerSeconds)
            case .open, .none:
                newStepMode = .restOpen
            }
        }

        onUpdateSummary(newStepMode)
        sheetDetent = .medium
        dismiss()
    }

    private static func extractFromStepMode(_ stepMode: StepMode) -> (
        exerciseMode: ExerciseMode?, restMode: RestMode?, seconds: Int, reps: Int
    ) {
        switch stepMode {
        case .exerciseTimed(let seconds):
            return (.timed, nil, seconds, 10)
        case .exerciseReps(let count):
            return (.reps, nil, 60, count)
        case .exerciseOpen:
            return (.open, nil, 60, 10)
        case .restTimed(let seconds):
            return (nil, .timed, seconds, 10)
        case .restOpen:
            return (nil, .open, 60, 10)
        }
    }
}

// MARK: - Subviews unique to EditStepSheet

private struct DeleteConfirmView: View {
    let onCancel: () -> Void
    let onDeleteConfirm: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Are you sure you want to delete this step?")
                .foregroundColor(.secondary)
            HStack {
                Button("Cancel") { onCancel() }
                Button(role: .destructive) {
                    onDeleteConfirm()
                } label: {
                    Text("Delete")
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct InfoView: View {
    let title: String
    let message: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(message).foregroundColor(.secondary)
            Button("Close") { onClose() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}
