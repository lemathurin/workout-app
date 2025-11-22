import SwiftData
import SwiftUI

// MARK: - Exercise Mode Selector

struct ExerciseModeSelector: View {
    let currentMode: ExerciseMode?
    let primaryLabel: String
    let secondaryLabel: String
    let onSelectTimed: () -> Void
    let onSelectReps: () -> Void
    let onSelectOpen: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Timed") { onSelectTimed() }
                Button("Reps") { onSelectReps() }
                Button("Open") { onSelectOpen() }
                Button(secondaryLabel) { onSecondary() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Timed Picker

struct TimedPicker: View {
    @Binding var seconds: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(stride(from: 5, through: 600, by: 5))

    var body: some View {
        VStack(spacing: 16) {
            Picker("Seconds", selection: $seconds) {
                ForEach(options, id: \.self) { sec in
                    Text("\(sec) sec").tag(sec)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button(secondaryLabel) { onSecondary() }
                Button(primaryLabel) { onPrimary() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Reps Picker

struct RepsPicker: View {
    @Binding var reps: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(1...100)

    var body: some View {
        VStack(spacing: 16) {
            Picker("Reps", selection: $reps) {
                ForEach(options, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button(secondaryLabel) { onSecondary() }
                Button(primaryLabel) { onPrimary() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Rest Mode Selector

struct RestModeSelector: View {
    let currentMode: RestMode?
    let primaryLabel: String
    let secondaryLabel: String
    let onSelectTimed: () -> Void
    let onSelectOpen: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Timed") { onSelectTimed() }
                Button("Open") { onSelectOpen() }
                Button(secondaryLabel) { onSecondary() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Rest Timed Picker

struct RestTimedPicker: View {
    @Binding var seconds: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(stride(from: 5, through: 600, by: 5))

    var body: some View {
        VStack(spacing: 16) {
            Picker("Seconds", selection: $seconds) {
                ForEach(options, id: \.self) { sec in
                    Text("\(sec) sec").tag(sec)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button(secondaryLabel) { onSecondary() }
                Button(primaryLabel) { onPrimary() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Repeat Count Picker

struct RepeatCountPicker: View {
    @Binding var count: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(2...20)

    var body: some View {
        VStack(spacing: 16) {
            Picker("Count", selection: $count) {
                ForEach(options, id: \.self) { value in
                    Text("\(value)x").tag(value)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button(secondaryLabel) { onSecondary() }
                Button(primaryLabel) { onPrimary() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Exercise Picker

struct ExercisePickerView: View {
    @Binding var selectedId: String?
    @Binding var selectedName: String?
    let onBack: () -> Void
    let onDone: () -> Void

    @Query private var exercises: [Exercise]

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Back") { onBack() }
                Spacer()
                Color.clear.frame(width: 60, height: 1)
            }
            .padding(.horizontal)

            List(exercises, id: \.id) { exercise in
                Button {
                    selectedId = exercise.id
                    selectedName = exercise.getName()
                    onDone()
                } label: {
                    Text(exercise.getName())
                }
            }
        }
    }
}
