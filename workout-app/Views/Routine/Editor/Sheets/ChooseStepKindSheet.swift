import SwiftUI

struct ChooseStepKindSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showExerciseFlow: Bool = false
    @State private var showRestFlow: Bool = false
    @State private var showRepeatCountSheet: Bool = false

    let onAddExercise: (String, String, StepMode) -> Void
    let onAddRest: (StepMode) -> Void
    let onStartRepeatFlow: (Int) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Button {
                    showExerciseFlow = true
                } label: {
                    Text("Exercise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showRestFlow = true
                } label: {
                    Text("Rest")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    showRepeatCountSheet = true
                } label: {
                    Text("Repeat")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
            .padding()
            .navigationTitle("Add a step")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showExerciseFlow) {
                ExerciseFlowSheet(
                    onAddExercise: { exerciseId, name, mode in
                        onAddExercise(exerciseId, name, mode)
                        dismiss()
                    },
                    onCancel: {
                        showExerciseFlow = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $showRestFlow) {
                RestFlowSheet(
                    onAddRest: { mode in
                        onAddRest(mode)
                        dismiss()
                    },
                    onCancel: {
                        showRestFlow = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $showRepeatCountSheet) {
                RepeatCountSheet(
                    onStartRepeatFlow: { count in
                        onStartRepeatFlow(count)
                        dismiss()
                    },
                    onCancel: {
                        showRepeatCountSheet = false
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
        }
    }
}

#Preview {
    ChooseStepKindSheet(
        onAddExercise: { _, _, _ in },
        onAddRest: { _ in },
        onStartRepeatFlow: { _ in }
    )
}
