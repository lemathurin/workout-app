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
                TimedPickerSheet(
                    seconds: $timedSeconds,
                    onNext: {
                        showTimedPicker = false
                        showExercisePicker = true
                    },
                    onCancel: {
                        showTimedPicker = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $showRepsPicker) {
                RepsPickerSheet(
                    reps: $repsCount,
                    onNext: {
                        showRepsPicker = false
                        showExercisePicker = true
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
                    mode: selectedMode ?? .open,
                    seconds: timedSeconds,
                    reps: repsCount,
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

#Preview {
    ExerciseFlowSheet(
        onAddExercise: { _, _, _ in },
        onCancel: {}
    )
}
