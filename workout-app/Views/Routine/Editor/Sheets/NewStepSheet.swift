import SwiftData
import SwiftUI

struct NewStepSheet: View {
    @Binding var sheetDetent: PresentationDetent
    @State private var selectedStepType: StepType = .exercise
    @Environment(\.dismiss) private var dismiss
    let onAddStep: (String?, String?, StepMode) -> Void
    let onStartRepeatFlow: (Int) -> Void

    enum FlowStep: Hashable {
        case chooseKind, exerciseMode, timed, reps, restMode, restTimed, exercisePicker, repeatCount
    }

    @State private var flow: FlowStep = .chooseKind
    @State private var exerciseModeSelection: ExerciseMode?
    @State private var timerSeconds: Int = 60
    @State private var selectedExerciseId: String?
    @State private var selectedExerciseName: String?
    @State private var restModeSelection: RestMode?
    @State private var restSeconds: Int = 30
    @State private var repsCount: Int = 10
    @State private var repeatCountSelection: Int = 2

    var body: some View {
        NavigationStack {
            Group {
                switch flow {
                case .chooseKind:
                    ChooseKindView(
                        onSelect: { kind in
                            selectedStepType = kind
                            if kind == .exercise {
                                flow = .exerciseMode
                            } else if kind == .rest {
                                flow = .restMode
                            } else if kind == .repeats {
                                flow = .repeatCount
                            }
                        },
                        onCancel: { dismiss() }
                    )
                case .exerciseMode:
                    ExerciseModeSelector(
                        currentMode: exerciseModeSelection,
                        primaryLabel: "Next",
                        secondaryLabel: "Back",
                        onSelectTimed: {
                            exerciseModeSelection = .timed
                            flow = .timed
                        },
                        onSelectReps: {
                            exerciseModeSelection = .reps
                            flow = .reps
                        },
                        onSelectOpen: {
                            exerciseModeSelection = .open
                            sheetDetent = .large
                            flow = .exercisePicker
                        },
                        onSecondary: { flow = .chooseKind }
                    )
                case .timed:
                    TimedPicker(
                        seconds: $timerSeconds,
                        primaryLabel: "Next",
                        secondaryLabel: "Back",
                        onPrimary: {
                            sheetDetent = .large
                            flow = .exercisePicker
                        },
                        onSecondary: { flow = .exerciseMode }
                    )
                case .reps:
                    RepsPicker(
                        reps: $repsCount,
                        primaryLabel: "Next",
                        secondaryLabel: "Back",
                        onPrimary: {
                            sheetDetent = .large
                            flow = .exercisePicker
                        },
                        onSecondary: { flow = .exerciseMode }
                    )
                case .exercisePicker:
                    ExercisePickerView(
                        selectedId: $selectedExerciseId,
                        selectedName: $selectedExerciseName,
                        onBack: {
                            sheetDetent = .medium
                            flow = .exerciseMode
                        },
                        onDone: {
                            if let exerciseId = selectedExerciseId, let name = selectedExerciseName,
                                let mode = exerciseModeSelection
                            {
                                let stepMode: StepMode
                                switch mode {
                                case .timed:
                                    stepMode = .exerciseTimed(seconds: timerSeconds)
                                case .reps:
                                    stepMode = .exerciseReps(count: repsCount)
                                case .open:
                                    stepMode = .exerciseOpen
                                }
                                onAddStep(exerciseId, name, stepMode)
                            }
                            sheetDetent = .medium
                            dismiss()
                        }
                    )
                case .restMode:
                    RestModeSelector(
                        currentMode: restModeSelection,
                        primaryLabel: "Next",
                        secondaryLabel: "Back",
                        onSelectTimed: {
                            restModeSelection = .timed
                            flow = .restTimed
                        },
                        onSelectOpen: {
                            onAddStep(nil, nil, .restOpen)
                            dismiss()
                        },
                        onSecondary: { flow = .chooseKind }
                    )
                case .restTimed:
                    RestTimedPicker(
                        seconds: $restSeconds,
                        primaryLabel: "Next",
                        secondaryLabel: "Back",
                        onPrimary: {
                            onAddStep(nil, nil, .restTimed(seconds: restSeconds))
                            dismiss()
                        },
                        onSecondary: { flow = .restMode }
                    )
                case .repeatCount:
                    RepeatCountPicker(
                        count: $repeatCountSelection,
                        primaryLabel: "Next",
                        secondaryLabel: "Back",
                        onPrimary: {
                            onStartRepeatFlow(repeatCountSelection)
                            dismiss()
                        },
                        onSecondary: { flow = .chooseKind }
                    )
                }
            }
            .navigationTitle(currentTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var currentTitle: String {
        switch flow {
        case .chooseKind:
            return "Add a step"
        case .exerciseMode:
            return "Exercise Type"
        case .timed:
            return "Timed"
        case .reps:
            return "Reps"
        case .exercisePicker:
            return "Choose Exercise"
        case .restMode:
            return "Rest Type"
        case .restTimed:
            return "Rest (Timed)"
        case .repeatCount:
            return "Repeat Count"
        }
    }
}

#Preview {
    NewStepSheet(
        sheetDetent: .constant(.medium), onAddStep: { _, _, _ in }, onStartRepeatFlow: { _ in })
}

// Subviews used in the flow

private struct ChooseKindView: View {
    let onSelect: (StepType) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Exercise") { onSelect(.exercise) }
                Button("Rest") { onSelect(.rest) }
                Button("Repeat") { onSelect(.repeats) }
                Button("Cancel") { onCancel() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
