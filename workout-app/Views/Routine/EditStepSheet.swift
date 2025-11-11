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
                        ExerciseTypeEditView(
                            currentMode: exerciseModeSelection,
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
                            onCancel: { dismiss() }
                        )
                    } else {
                        RestModeEditView(
                            currentMode: restModeSelection,
                            onSelectTimed: {
                                restModeSelection = .timed
                                editStep = .selectAmount
                            },
                            onSelectOpen: {
                                restModeSelection = .open
                                applyUpdateAndClose()
                            },
                            onCancel: { dismiss() }
                        )
                    }
                case .selectAmount:
                    if isExercise {
                        switch exerciseModeSelection {
                        case .timed:
                            TimedEditView(
                                seconds: $timerSeconds,
                                onCancel: { dismiss() },
                                onSave: { applyUpdateAndClose() }
                            )
                        case .reps:
                            RepsEditView(
                                reps: $repsCount,
                                onCancel: { dismiss() },
                                onSave: { applyUpdateAndClose() }
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
                            RestTimedEditView(
                                seconds: $timerSeconds,
                                onCancel: { dismiss() },
                                onSave: { applyUpdateAndClose() }
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
        case .selectType: return "Edit Step Type"
        case .selectAmount: return "Edit Amount"
        case .confirmDelete: return "Delete Step"
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

    private static func extractFromStepMode(_ stepMode: StepMode) -> (exerciseMode: ExerciseMode?, restMode: RestMode?, seconds: Int, reps: Int) {
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

// MARK: - Subviews (styled like NewStepSheet but focused)

private struct ExerciseTypeEditView: View {
    let currentMode: ExerciseMode?
    let onSelectTimed: () -> Void
    let onSelectReps: () -> Void
    let onSelectOpen: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Exercise type").font(.headline)
            HStack {
                Button("Timed") { onSelectTimed() }
                Button("Reps") { onSelectReps() }
                Button("Open") { onSelectOpen() }
                Button("Cancel") { onCancel() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct RestModeEditView: View {
    let currentMode: RestMode?
    let onSelectTimed: () -> Void
    let onSelectOpen: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Rest type").font(.headline)
            HStack {
                Button("Timed") { onSelectTimed() }
                Button("Open") { onSelectOpen() }
                Button("Cancel") { onCancel() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct TimedEditView: View {
    @Binding var seconds: Int
    let onCancel: () -> Void
    let onSave: () -> Void

    private let options = Array(stride(from: 5, through: 600, by: 5))

    var body: some View {
        VStack(spacing: 16) {
            Text("Timed").font(.headline)
            Picker("Seconds", selection: $seconds) {
                ForEach(options, id: \.self) { sec in
                    Text("\(sec) sec").tag(sec)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button("Cancel") { onCancel() }
                Button("Save") { onSave() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct RepsEditView: View {
    @Binding var reps: Int
    let onCancel: () -> Void
    let onSave: () -> Void

    private let options = Array(1...100)

    var body: some View {
        VStack(spacing: 16) {
            Text("Reps").font(.headline)
            Picker("Reps", selection: $reps) {
                ForEach(options, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button("Cancel") { onCancel() }
                Button("Save") { onSave() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct RestTimedEditView: View {
    @Binding var seconds: Int
    let onCancel: () -> Void
    let onSave: () -> Void

    private let options = Array(stride(from: 5, through: 600, by: 5))

    var body: some View {
        VStack(spacing: 16) {
            Text("Rest (Timed)").font(.headline)
            Picker("Seconds", selection: $seconds) {
                ForEach(options, id: \.self) { sec in
                    Text("\(sec) sec").tag(sec)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button("Cancel") { onCancel() }
                Button("Save") { onSave() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct DeleteConfirmView: View {
    let onCancel: () -> Void
    let onDeleteConfirm: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Delete Step").font(.headline)
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
            Text(title).font(.headline)
            Text(message).foregroundColor(.secondary)
            Button("Close") { onClose() }
                .buttonStyle(.bordered)
        }
        .padding()
    }
}