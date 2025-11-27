import SwiftUI

struct ExerciseFlowSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: ExerciseMode?
    @State private var showTimedPicker: Bool = false
    @State private var showRepsPicker: Bool = false
    @State private var showExercisePicker: Bool = false
    @State private var timedSeconds: Int = 60
    @State private var repsCount: Int = 10

    let onAddExercise: (String, String, StepMode) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ExerciseModeSelector(
                currentMode: selectedMode,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onSelectTimed: {
                    selectedMode = .timed
                    showTimedPicker = true
                },
                onSelectReps: {
                    selectedMode = .reps
                    showRepsPicker = true
                },
                onSelectOpen: {
                    selectedMode = .open
                    showExercisePicker = true
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Exercise Type")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showTimedPicker) {
                TimedPickerSheetWithExercisePicker(
                    seconds: $timedSeconds,
                    onAddExercise: { exerciseId, name in
                        onAddExercise(exerciseId, name, .exerciseTimed(seconds: timedSeconds))
                        dismiss()
                    },
                    onCancel: {
                        showTimedPicker = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $showRepsPicker) {
                RepsPickerSheetWithExercisePicker(
                    reps: $repsCount,
                    onAddExercise: { exerciseId, name in
                        onAddExercise(exerciseId, name, .exerciseReps(count: repsCount))
                        dismiss()
                    },
                    onCancel: {
                        showRepsPicker = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerSheet(
                    mode: .open,
                    seconds: 0,
                    reps: 0,
                    onSelectExercise: { exerciseId, name, stepMode in
                        onAddExercise(exerciseId, name, stepMode)
                        dismiss()
                    },
                    onCancel: {
                        showExercisePicker = false
                    }
                )
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)
            }
        }
    }
}

// Wrapper for TimedPickerSheet that includes the exercise picker as a nested sheet
private struct TimedPickerSheetWithExercisePicker: View {
    @Binding var seconds: Int
    @State private var showExercisePicker = false
    let onAddExercise: (String, String) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            TimedPicker(
                seconds: $seconds,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onPrimary: {
                    showExercisePicker = true
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Timed")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerSheet(
                    mode: .timed,
                    seconds: seconds,
                    reps: 0,
                    onSelectExercise: { exerciseId, name, _ in
                        onAddExercise(exerciseId, name)
                    },
                    onCancel: {
                        showExercisePicker = false
                    }
                )
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)
            }
        }
    }
}

// Wrapper for RepsPickerSheet that includes the exercise picker as a nested sheet
private struct RepsPickerSheetWithExercisePicker: View {
    @Binding var reps: Int
    @State private var showExercisePicker = false
    let onAddExercise: (String, String) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            RepsPicker(
                reps: $reps,
                primaryLabel: "Next",
                secondaryLabel: "Back",
                onPrimary: {
                    showExercisePicker = true
                },
                onSecondary: {
                    onCancel()
                }
            )
            .navigationTitle("Reps")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExercisePicker) {
                ExercisePickerSheet(
                    mode: .reps,
                    seconds: 0,
                    reps: reps,
                    onSelectExercise: { exerciseId, name, _ in
                        onAddExercise(exerciseId, name)
                    },
                    onCancel: {
                        showExercisePicker = false
                    }
                )
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)
            }
        }
    }
}

#Preview {
    ExerciseFlowSheet(
        onAddExercise: { _, _, _ in },
        onCancel: {}
    )
}
