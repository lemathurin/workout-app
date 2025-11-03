import SwiftUI
import SwiftData

struct NewStepSheet: View {
    @Binding var sheetDetent: PresentationDetent
    @State private var selectedStepType: StepType = .exercise
    @Environment(\.dismiss) private var dismiss
    
    enum FlowStep: Hashable { case chooseKind, exerciseMode, timed, reps, restMode, restTimed, exercisePicker }
    enum ExerciseMode { case timed, reps, open }
    enum RestMode { case timed, open }
    
    @State private var flow: FlowStep = .chooseKind
    @State private var exerciseModeSelection: ExerciseMode?
    @State private var timerSeconds: Int = 60
    // Removed nested sheet trigger; we’ll use inline picker
    @State private var selectedExerciseName: String?
    @State private var restModeSelection: RestMode?
    @State private var restSeconds: Int = 30
    @State private var repsCount: Int = 10
    
    var body: some View {
        NavigationStack {
            Group {
                switch flow {
                case .chooseKind:
                    ChooseKindView(
                        onSelect: { kind in
                            selectedStepType = kind
                            if kind == .exercise { flow = .exerciseMode }
                            else if kind == .rest { flow = .restMode }
                            else if kind == .repeats { dismiss() }
                        },
                        onCancel: { dismiss() }
                    )
                case .exerciseMode:
                    ExerciseModeView(
                        onBack: { flow = .chooseKind },
                        onSelectTimed: { exerciseModeSelection = .timed; flow = .timed },
                        onSelectReps: { exerciseModeSelection = .reps; flow = .reps },
                        onSelectOpen: { exerciseModeSelection = .open; sheetDetent = .large; flow = .exercisePicker }
                    )
                case .timed:
                    TimedView(
                        seconds: $timerSeconds,
                        onBack: { flow = .exerciseMode },
                        onNext: { sheetDetent = .large; flow = .exercisePicker }
                    )
                case .reps:
                    RepsView(
                        reps: $repsCount,
                        onBack: { flow = .exerciseMode },
                        onNext: { sheetDetent = .large; flow = .exercisePicker }
                    )
                case .exercisePicker:
                    ExercisePickerView(
                        selectedName: $selectedExerciseName,
                        onBack: { sheetDetent = .medium; flow = .exerciseMode },
                        onDone: {
                            sheetDetent = .medium
                            dismiss()
                        }
                    )
                case .restMode:
                    RestModeView(
                        onBack: { flow = .chooseKind },
                        onSelectTimed: { restModeSelection = .timed; flow = .restTimed },
                        onSelectOpen: { restModeSelection = .open; dismiss() }
                    )
                case .restTimed:
                    RestTimedView(
                        seconds: $restSeconds,
                        onBack: { flow = .restMode },
                        onNext: { dismiss() }
                    )
                default:
                    EmptyView()
                }
            }
            .navigationTitle("New Step")
            // Removed nested .sheet for exercise picker
        }
    }
}

#Preview {
    NewStepSheet(sheetDetent: .constant(.medium))
}

// Subviews used in the flow

private struct ChooseKindView: View {
    let onSelect: (StepType) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Add a step").font(.headline)
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

private struct ExerciseModeView: View {
    let onBack: () -> Void
    let onSelectTimed: () -> Void
    let onSelectReps: () -> Void
    let onSelectOpen: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Exercise type").font(.headline)
            HStack {
                Button("Timed") { onSelectTimed() }
                Button("Reps") { onSelectReps() }
                Button("Open") { onSelectOpen() }
                Button("Back") { onBack() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct TimedView: View {
    @Binding var seconds: Int
    let onBack: () -> Void
    let onNext: () -> Void
    
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
                Button("Back") { onBack() }
                Button("Next") { onNext() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct RepsView: View {
    @Binding var reps: Int
    let onBack: () -> Void
    let onNext: () -> Void

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
                Button("Back") { onBack() }
                Button("Next") { onNext() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct ExercisePickerView: View {
    @Binding var selectedName: String?
    let onBack: () -> Void
    let onDone: () -> Void
    
    @Query private var exercises: [Exercise]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Back") { onBack() }
                Spacer()
                Text("Choose Exercise").font(.headline)
                Spacer()
                Color.clear.frame(width: 60, height: 1)
            }
            .padding(.horizontal)
            
            List(exercises, id: \.id) { exercise in
                Button {
                    selectedName = exercise.getName()
                    onDone()
                } label: {
                    Text(exercise.getName())
                }
            }
        }
    }
}

// Subviews used in the rest flow
private struct RestModeView: View {
    let onBack: () -> Void
    let onSelectTimed: () -> Void
    let onSelectOpen: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Rest type").font(.headline)
            HStack {
                Button("Timed") { onSelectTimed() }
                Button("Open") { onSelectOpen() }
                Button("Back") { onBack() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

private struct RestTimedView: View {
    @Binding var seconds: Int
    let onBack: () -> Void
    let onNext: () -> Void

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
                Button("Back") { onBack() }
                Button("Next") { onNext() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
