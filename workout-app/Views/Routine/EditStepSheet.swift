import SwiftUI

enum StepEditAction { case changeType, changeAmount, delete }
enum StepCategory { case exercise, rest }
enum ExerciseMode { case timed, reps, open }
enum RestMode { case timed, open }

private enum EditStep { case selectType, selectAmount, confirmDelete }

struct EditStepSheet: View {
    @Binding var sheetDetent: PresentationDetent
    let initialSummary: String
    let action: StepEditAction
    let onUpdateSummary: (String) -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var category: StepCategory = .exercise
    @State private var exerciseName: String? = nil
    @State private var exerciseModeSelection: ExerciseMode? = .open
    @State private var restModeSelection: RestMode? = .open
    @State private var timerSeconds: Int = 60
    @State private var repsCount: Int = 10
    @State private var editStep: EditStep

    init(
        sheetDetent: Binding<PresentationDetent>,
        initialSummary: String,
        action: StepEditAction,
        onUpdateSummary: @escaping (String) -> Void,
        onDelete: @escaping () -> Void
    ) {
        _sheetDetent = sheetDetent
        self.initialSummary = initialSummary
        self.action = action
        self.onUpdateSummary = onUpdateSummary
        self.onDelete = onDelete

        let parsed = EditStepSheet.parseSummary(initialSummary)
        _category = State(initialValue: parsed.category)
        _exerciseName = State(initialValue: parsed.exerciseName)
        _exerciseModeSelection = State(initialValue: parsed.exerciseMode)
        _restModeSelection = State(initialValue: parsed.restMode)
        _timerSeconds = State(initialValue: parsed.seconds)
        _repsCount = State(initialValue: parsed.reps)

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
                    if category == .exercise {
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
                    if category == .exercise {
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

    private var navigationTitle: String {
        switch editStep {
        case .selectType: return "Edit Step Type"
        case .selectAmount: return "Edit Amount"
        case .confirmDelete: return "Delete Step"
        }
    }

    private func applyUpdateAndClose() {
        switch category {
        case .exercise:
            let name = exerciseName ?? "Exercise"
            switch exerciseModeSelection {
            case .timed:
                onUpdateSummary("Exercise: \(name) – \(timerSeconds) sec")
            case .reps:
                onUpdateSummary("Exercise: \(name) – \(repsCount) reps")
            case .open, .none:
                onUpdateSummary("Exercise: \(name) – Open")
            }
        case .rest:
            switch restModeSelection {
            case .timed:
                onUpdateSummary("Rest – \(timerSeconds) sec")
            case .open, .none:
                onUpdateSummary("Rest – Open")
            }
        }
        sheetDetent = .medium
        dismiss()
    }

    private static func parseSummary(_ s: String) -> (category: StepCategory, exerciseName: String?, exerciseMode: ExerciseMode?, restMode: RestMode?, seconds: Int, reps: Int) {
        var category: StepCategory = .exercise
        var exerciseName: String? = nil
        var exerciseMode: ExerciseMode? = nil
        var restMode: RestMode? = nil
        var seconds = 60
        var reps = 10

        if s.hasPrefix("Exercise: ") {
            category = .exercise
            let afterPrefix = s.dropFirst("Exercise: ".count)
            if let sep = afterPrefix.range(of: " – ") {
                exerciseName = String(afterPrefix[..<sep.lowerBound])
                let suffix = String(afterPrefix[sep.upperBound...])
                if suffix == "Open" {
                    exerciseMode = .open
                } else if suffix.hasSuffix(" sec") {
                    let valueStr = suffix.replacingOccurrences(of: " sec", with: "")
                    seconds = Int(valueStr) ?? seconds
                    exerciseMode = .timed
                } else if suffix.hasSuffix(" reps") {
                    let valueStr = suffix.replacingOccurrences(of: " reps", with: "")
                    reps = Int(valueStr) ?? reps
                    exerciseMode = .reps
                }
            }
        } else if s.hasPrefix("Rest – ") {
            category = .rest
            let suffix = s.dropFirst("Rest – ".count)
            if suffix == "Open" {
                restMode = .open
            } else if suffix.hasSuffix(" sec") {
                let valueStr = suffix.replacingOccurrences(of: " sec", with: "")
                seconds = Int(valueStr) ?? seconds
                restMode = .timed
            }
        }

        return (category, exerciseName, exerciseMode, restMode, seconds, reps)
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