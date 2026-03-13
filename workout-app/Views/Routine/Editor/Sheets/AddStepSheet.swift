import SwiftUI

private enum AddStepFlow {
    case chooseKind
    case pickExercise
    case chooseMode
    case chooseRepeatCount
}

struct AddStepSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentFlow: AddStepFlow = .chooseKind

    // Step kind selection
    @State private var selectedKind: StepType?

    // Exercise picker
    @State private var selectedExerciseId: String?
    @State private var selectedExerciseName: String?

    // Mode + amount
    @State private var selectedExerciseMode: ExerciseMode?
    @State private var selectedRestMode: RestMode?
    @State private var timedSeconds: Int = 60
    @State private var repsCount: Int = 10

    // Repeat
    @State private var repeatCount: Int = 2

    let onAddExercise: (String, String, ExerciseStepMode) -> Void
    let onAddRest: (RestStepMode) -> Void
    let onAddRepeat: (Int) -> Void

    var body: some View {
        DynamicSheet(animation: .smooth(duration: 0.25, extraBounce: 0), maximized: currentFlow == .pickExercise) {
            VStack(spacing: 20) {
                ZStack {
                    switch currentFlow {
                    case .chooseKind:
                        ChooseKindStep(
                            onExercise: {
                                selectedKind = .exercise
                                goTo(.pickExercise)
                            },
                            onRest: {
                                selectedKind = .rest
                                goTo(.chooseMode)
                            },
                            onRepeat: {
                                selectedKind = .repeats
                                goTo(.chooseRepeatCount)
                            },
                            onCancel: { dismiss() }
                        )
                        .transition(.blurReplace(.upUp))
                    case .pickExercise:
                        PickExerciseStep(
                            selectedExerciseId: $selectedExerciseId,
                            selectedExerciseName: $selectedExerciseName,
                            onNext: { goTo(.chooseMode) },
                            onBack: { goTo(.chooseKind) }
                        )
                        .transition(.blurReplace(.downUp))
                    case .chooseMode:
                        ChooseModeStep(
                            isExercise: selectedKind == .exercise,
                            exerciseMode: $selectedExerciseMode,
                            restMode: $selectedRestMode,
                            timedSeconds: $timedSeconds,
                            repsCount: $repsCount,
                            onDone: { finishFlow() },
                            onBack: {
                                if selectedKind == .exercise {
                                    goTo(.pickExercise)
                                } else {
                                    goTo(.chooseKind)
                                }
                            }
                        )
                        .transition(.blurReplace(.downUp))
                    case .chooseRepeatCount:
                        RepeatCountStep(
                            count: $repeatCount,
                            onDone: {
                                onAddRepeat(repeatCount)
                                dismiss()
                            },
                            onBack: { goTo(.chooseKind) }
                        )
                        .transition(.blurReplace(.downUp))
                    }
                }
                .geometryGroup()
            }
            .padding([.horizontal, .top], currentFlow == .pickExercise ? 0 : 20)
        }
    }

    private func goTo(_ flow: AddStepFlow) {
        withAnimation(.smooth(duration: 0.25, extraBounce: 0)) {
            currentFlow = flow
        }
    }

    private func finishFlow() {
        if selectedKind == .exercise,
           let exerciseId = selectedExerciseId,
           let name = selectedExerciseName
        {
            let mode: ExerciseStepMode
            switch selectedExerciseMode {
            case .timed:
                mode = .timed(seconds: timedSeconds)
            case .reps:
                mode = .reps(count: repsCount)
            case .open, .none:
                mode = .open
            }
            onAddExercise(exerciseId, name, mode)
        } else if selectedKind == .rest {
            let mode: RestStepMode
            switch selectedRestMode {
            case .timed:
                mode = .timed(seconds: timedSeconds)
            case .open, .none:
                mode = .open
            }
            onAddRest(mode)
        }
        dismiss()
    }
}

// MARK: - Step 1: Choose Kind

private struct ChooseKindStep: View {
    let onExercise: () -> Void
    let onRest: () -> Void
    let onRepeat: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Add a Step")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Exercise", action: onExercise)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            Button("Rest", action: onRest)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            Button("Repeat", action: onRepeat)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            Button("Cancel", action: onCancel)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
        }
        .controlSize(.large)
    }
}

// MARK: - Step 2: Pick Exercise

private struct PickExerciseStep: View {
    @Binding var selectedExerciseId: String?
    @Binding var selectedExerciseName: String?
    let onNext: () -> Void
    let onBack: () -> Void

    var body: some View {
        ExercisePickerView(
            selectedId: $selectedExerciseId,
            selectedName: $selectedExerciseName,
            onBack: onBack,
            onDone: onNext
        )
        .clipShape(.rect(cornerRadius: 12))
    }
}

// MARK: - Step 3: Choose Mode + Amount

private struct ChooseModeStep: View {
    let isExercise: Bool
    @Binding var exerciseMode: ExerciseMode?
    @Binding var restMode: RestMode?
    @Binding var timedSeconds: Int
    @Binding var repsCount: Int
    let onDone: () -> Void
    let onBack: () -> Void

    @State private var showAmountPicker = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Choose Mode")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Back", action: onBack)
            }

            if showAmountPicker {
                amountPickerContent
            } else {
                modeSelectionContent
            }
        }
    }

    @ViewBuilder
    private var modeSelectionContent: some View {
        if isExercise {
            Button("Timed") {
                exerciseMode = .timed
                showAmountPicker = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            Button("Reps") {
                exerciseMode = .reps
                showAmountPicker = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            Button("Open") {
                exerciseMode = .open
                onDone()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        } else {
            Button("Timed") {
                restMode = .timed
                showAmountPicker = true
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)

            Button("Open") {
                restMode = .open
                onDone()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var amountPickerContent: some View {
        if isExercise && exerciseMode == .timed {
            TimedPicker(
                seconds: $timedSeconds,
                primaryLabel: "Done",
                secondaryLabel: "Back",
                onPrimary: onDone,
                onSecondary: { showAmountPicker = false }
            )
        } else if isExercise && exerciseMode == .reps {
            RepsPicker(
                reps: $repsCount,
                primaryLabel: "Done",
                secondaryLabel: "Back",
                onPrimary: onDone,
                onSecondary: { showAmountPicker = false }
            )
        } else if !isExercise && restMode == .timed {
            RestTimedPicker(
                seconds: $timedSeconds,
                primaryLabel: "Done",
                secondaryLabel: "Back",
                onPrimary: onDone,
                onSecondary: { showAmountPicker = false }
            )
        }
    }
}

// MARK: - Repeat Count Step

private struct RepeatCountStep: View {
    @Binding var count: Int
    let onDone: () -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Repeat Count")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Back", action: onBack)
            }

            RepeatCountPicker(
                count: $count,
                primaryLabel: "Done",
                secondaryLabel: "Back",
                onPrimary: onDone,
                onSecondary: onBack
            )
        }
    }
}
