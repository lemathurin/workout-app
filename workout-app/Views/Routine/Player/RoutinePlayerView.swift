import SwiftData
import SwiftUI

struct RoutinePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    @State private var viewModel: RoutinePlayerViewModel
    @State private var showCancelConfirmation = false

    let routine: Routine

    init(routine: Routine) {
        self.routine = routine
        _viewModel = State(initialValue: RoutinePlayerViewModel(routine: routine))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.state {
                case .playing, .paused:
                    playerContent
                case .completed:
                    completionContent
                case .cancelled:
                    EmptyView()
                }

                exerciseProgressFill
                restProgressFill
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close", systemImage: "xmark") {
                        showCancelConfirmation = true
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        viewModel.state == .paused ? "Resume" : "Pause",
                        systemImage: viewModel.state == .paused ? "play" : "pause"
                    ) {
                        viewModel.togglePause()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Previous Step", systemImage: "chevron.left") {
                        viewModel.goToPreviousStep()
                    }
                    .disabled(viewModel.currentStepIndex == 0)

                    Spacer()

                    Button("\(viewModel.currentStepIndex + 1)/\(viewModel.steps.count)") {}

                    Spacer()

                    Button("Next Step", systemImage: "chevron.right") {
                        viewModel.completeCurrentStep()
                    }
                }
            }
            .toolbarVisibility(
                viewModel.state == .completed ? .hidden : .automatic,
                for: .bottomBar
            )
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState == .cancelled {
                dismiss()
            }
        }
        .confirmationDialog(
            "End Routine?",
            isPresented: $showCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Routine", role: .destructive) {
                viewModel.cancelRoutine()
            }
        } message: {
            Text("Your progress will be lost.")
        }
    }

    // MARK: - Player Content

    private var playerContent: some View {
        VStack(spacing: 24) {
            if let step = viewModel.currentStep {
                stepModeDisplay(for: step)

                Text(stepName(for: step))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(step.isRest ? "Rest" : stepName(for: step))
            }
        }
    }

    @ViewBuilder
    private func stepModeDisplay(for step: PlayableStep) -> some View {
        switch step.mode {
        case .exerciseTimed, .restTimed:
            CountdownDisplayView(seconds: viewModel.secondsRemaining)
        case .exerciseReps(let count):
            VStack {
                Text("\(count)")
                    .font(.system(size: 80, weight: .semibold, design: .rounded))
                    .font(.caption)
                    .foregroundStyle(.primary)
                Text("reps")
                    .font(.title)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(count) repetitions")
        case .exerciseOpen, .restOpen:
            Text("Complete when ready")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Completion Content

    private var completionContent: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(.green)

            Text("Routine Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fontDesign(.rounded)

            Text(routine.getName())
                .font(.title2)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Progress Fills

    private var exerciseProgressFill: some View {
        GeometryReader { geometry in
            Rectangle()
                .glassEffect(
                    .clear.tint(Color(red: 0.3, green: 1, blue: 0.4).opacity(0.6)),
                    in: .rect
                )
                .frame(height: geometry.size.height * viewModel.exerciseProgress)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .animation(
                    .interpolatingSpring(stiffness: 100, damping: 10),
                    value: viewModel.exerciseProgress)
        }
        .ignoresSafeArea()
    }

    private var restProgressFill: some View {
        GeometryReader { geometry in
            Rectangle()
                .glassEffect(
                    .clear.tint(Color.blue.opacity(0.5)),
                    in: .rect
                )
                .frame(height: geometry.size.height * viewModel.restProgress)
                .frame(maxHeight: .infinity, alignment: .top)
                .animation(
                    .interpolatingSpring(stiffness: 100, damping: 10), value: viewModel.restProgress
                )
        }
        .ignoresSafeArea()
    }

    // MARK: - Helpers

    private func stepName(for step: PlayableStep) -> String {
        if step.isRest {
            return "Rest"
        }
        guard let exerciseId = step.exerciseId else {
            return "Exercise"
        }
        return exercises.first { $0.id == exerciseId }?.getName() ?? "Exercise"
    }
}

// MARK: - Countdown Display

struct CountdownDisplayView: View {
    let seconds: Int

    private var minutes: Int { seconds / 60 }
    private var remainingSeconds: Int { seconds % 60 }

    var body: some View {
        Text(formattedTime)
            .font(.system(size: 80, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary)
            .monospacedDigit()
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.2), value: seconds)
            .accessibilityLabel("\(minutes) minutes and \(remainingSeconds) seconds remaining")
    }

    private var formattedTime: String {
        if minutes > 0 {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
        return "\(remainingSeconds)"
    }
}

// MARK: - Preview

#Preview {
    let routine = Routine(
        name: "Test Routine",
        steps: [
            RoutineStep(type: .exercise, exerciseId: "pushups", duration: 5, order: 1),
            RoutineStep(type: .rest, duration: 5, order: 0),
            RoutineStep(type: .exercise, exerciseId: "pushups", duration: 5, order: 2),
            RoutineStep(type: .exercise, exerciseId: "pushups", duration: 5, order: 3),
            RoutineStep(type: .exercise, exerciseId: "squats", count: 15, order: 4),
        ])

    RoutinePlayerView(routine: routine)
        .modelContainer(for: [Routine.self, Exercise.self])
}
