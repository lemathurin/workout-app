import SwiftUI

struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedExerciseId: String?
    @State private var selectedExerciseName: String?

    let mode: ExerciseMode
    let seconds: Int
    let reps: Int
    let onSelectExercise: (String, String, StepMode) -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ExercisePickerView(
                selectedId: $selectedExerciseId,
                selectedName: $selectedExerciseName,
                onBack: {
                    onCancel()
                },
                onDone: {
                    if let exerciseId = selectedExerciseId,
                        let name = selectedExerciseName
                    {
                        let stepMode: StepMode
                        switch mode {
                        case .timed:
                            stepMode = .exerciseTimed(seconds: seconds)
                        case .reps:
                            stepMode = .exerciseReps(count: reps)
                        case .open:
                            stepMode = .exerciseOpen
                        }
                        onSelectExercise(exerciseId, name, stepMode)
                    }
                }
            )
            .navigationTitle("Choose Exercise")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ExercisePickerSheet(
        mode: .timed,
        seconds: 60,
        reps: 10,
        onSelectExercise: { _, _, _ in },
        onCancel: {}
    )
}
