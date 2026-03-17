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

    @State private var showInfo = false

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text("routine.edit.addAStep")
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Info", systemImage: "questionmark.circle.fill") {
                    showInfo = true
                }
                .labelStyle(.iconOnly)
                .font(.title)
                .foregroundStyle(Color.gray, Color.primary.opacity(0.1))
            }
            
            BigCardButton(
                title: "common.exercise",
                description: "routine.edit.exercice.description",
                action: onExercise
            )
            
            HStack(spacing: 12) {
                BigCardButton(
                    title: "common.rest",
                    description: "routine.edit.rest.description",
                    action: onRest
                )

                BigCardButton(
                    title: "common.repeat",
                    description: "routine.edit.repeat.description",
                    action: onRepeat
                )
            }

            Button("common.cancel", action: onCancel)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .buttonSizing(.flexible)
                .foregroundStyle(.primary)
        }
        .sheet(isPresented: $showInfo) {
            AddStepInfoSheet()
        }
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

    private var titleText: String {
        guard showAmountPicker else { return String(localized: "routine.edit.chooseMode") }
        if (isExercise && exerciseMode == .timed) || (!isExercise && restMode == .timed) {
            return String(localized: "routine.edit.howLong")
        } else if isExercise && exerciseMode == .reps {
            return String(localized: "routine.edit.howMany")
        }
        return String(localized: "routine.edit.chooseMode")
    }

    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Text(titleText)
                    .font(.title)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
            BigCardButton(
                title: "routine.edit.timed",
                description: "routine.edit.timed.description"
            ) {
                exerciseMode = .timed
                showAmountPicker = true
            }

            HStack(spacing: 12) {
                BigCardButton(
                    title: "routine.edit.repetitions",
                    description: "routine.edit.repetitions.description"
                ) {
                    exerciseMode = .reps
                    showAmountPicker = true
                }

                BigCardButton(
                    title: "routine.edit.open",
                    description: "routine.edit.open.description"
                ) {
                    exerciseMode = .open
                    onDone()
                }
            }

            Button("common.back", action: onBack)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .buttonSizing(.flexible)
                .foregroundStyle(.primary)
        } else {
            HStack(spacing: 12) {
                BigCardButton(
                    title: "routine.edit.timed",
                    description: "routine.edit.timed.description"
                ) {
                    restMode = .timed
                    showAmountPicker = true
                }

                BigCardButton(
                    title: "routine.edit.open",
                    description: "routine.edit.open.description"
                ) {
                    restMode = .open
                    onDone()
                }
            }
            
            Button("common.back", action: onBack)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .buttonSizing(.flexible)
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private var amountPickerContent: some View {
        if isExercise && exerciseMode == .timed {
            TimedPicker(
                seconds: $timedSeconds,
                primaryLabel: String(localized: "common.done"),
                secondaryLabel: String(localized: "common.back"),
                onPrimary: onDone,
                onSecondary: { showAmountPicker = false }
            )
        } else if isExercise && exerciseMode == .reps {
            RepsPicker(
                reps: $repsCount,
                primaryLabel: String(localized: "common.done"),
                secondaryLabel: String(localized: "common.back"),
                onPrimary: onDone,
                onSecondary: { showAmountPicker = false }
            )
        } else if !isExercise && restMode == .timed {
            RestTimedPicker(
                seconds: $timedSeconds,
                primaryLabel: String(localized: "common.done"),
                secondaryLabel: String(localized: "common.back"),
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
        VStack(spacing: 18) {
            Text("routine.edit.repeatCount")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)

            RepeatCountPicker(
                count: $count,
                primaryLabel: String(localized: "common.done"),
                secondaryLabel: String(localized: "common.back"),
                onPrimary: onDone,
                onSecondary: onBack
            )
        }
    }
}
