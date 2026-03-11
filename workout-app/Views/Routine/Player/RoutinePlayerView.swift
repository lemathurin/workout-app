import SwiftData
import SwiftUI

struct RoutinePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    @State private var viewModel: RoutinePlayerViewModel
    @State private var showCancelConfirmation = false
    @State private var wasPlayingBeforeInterruption = false
    @State private var showStepList = false

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
                    Button("Close", systemImage: "xmark", role: .destructive) {
                        wasPlayingBeforeInterruption = viewModel.state == .playing
                        if wasPlayingBeforeInterruption {
                            viewModel.togglePause()
                        }
                        showCancelConfirmation = true
                    }
//                    .buttonStyle(.glassProminent)
//                    .tint(.red)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.state == .paused {
                        Button("Resume", systemImage: "play") {
                            viewModel.togglePause()
                        }
                        .buttonStyle(.glassProminent)
                        .tint(pausedFillColor)
                    } else {
                        Button("Pause", systemImage: "pause") {
                            viewModel.togglePause()
                        }
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    if viewModel.state == .completed {
                        Button("Restart") {
                            viewModel.restart()
                        }

                        Spacer()

                        Button("\(viewModel.currentStepIndex + 1) of \(viewModel.steps.count)") {
                            wasPlayingBeforeInterruption = viewModel.state == .playing
                            if wasPlayingBeforeInterruption {
                                viewModel.togglePause()
                            }
                            showStepList = true
                        }

                        Spacer()

                        Button("Finish", role: .confirm) {
                            dismiss()
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.green)
                    } else {
                        Button("Previous Step", systemImage: "chevron.left") {
                            viewModel.goToPreviousStep()
                        }
                        .disabled(viewModel.currentStepIndex == 0)

                        Spacer()

                        Button("\(viewModel.currentStepIndex + 1) of \(viewModel.steps.count)") {
                            wasPlayingBeforeInterruption = viewModel.state == .playing
                            if wasPlayingBeforeInterruption {
                                viewModel.togglePause()
                            }
                            showStepList = true
                        }

                        Spacer()

                        if let step = viewModel.currentStep, step.mode.isManualCompletion {
                            Button("Complete") {
                                viewModel.completeCurrentStep()
                            }
                            .buttonStyle(.glassProminent)
                            .tint(.green)
                            .transition(.blurReplace)
                        } else {
                            Button("Next Step", systemImage: "chevron.right") {
                                viewModel.completeCurrentStep()
                            }
                            .transition(.blurReplace)
                        }
                    }
                }
            }
            .animation(.smooth, value: viewModel.currentStepIndex)
            .toolbarVisibility(
                viewModel.state == .completed ? .hidden : .automatic,
                for: .navigationBar
            )
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState == .cancelled {
                dismiss()
            }
        }
        .onChange(of: showCancelConfirmation) { _, isShowing in
            if !isShowing && wasPlayingBeforeInterruption && viewModel.state == .paused {
                viewModel.togglePause()
            }
        }
        .sheet(isPresented: $showStepList, onDismiss: {
            if wasPlayingBeforeInterruption && viewModel.state == .paused {
                viewModel.togglePause()
            }
        }) {
            StepListSheet(
                steps: viewModel.steps,
                currentStepIndex: viewModel.currentStepIndex,
                currentStepProgress: viewModel.timerProgress,
                onStepSelected: { index in
                    viewModel.goToStep(at: index)
                    showStepList = false
                }
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            "End Routine?",
            isPresented: $showCancelConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Routine", role: .destructive) {
                viewModel.cancelRoutine()
            }
            Button("Continue") {}
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
        VStack(spacing: 20) {
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
        }
    }

    // MARK: - Progress Fill Colors

    private let exerciseFillColor = Color(red: 0.3, green: 1, blue: 0.4).opacity(0.6)
    private let restFillColor = Color.cyan.opacity(0.5)
//    private let pausedFillColor = Color(red: 1.0, green: 0.9, blue: 0.49)
    private let pausedFillColor = Color.yellow

    private var exerciseTint: Color {
        viewModel.state == .paused ? pausedFillColor.opacity(0.6) : exerciseFillColor
    }

    private var restTint: Color {
        viewModel.state == .paused ? pausedFillColor.opacity(0.5) : restFillColor
    }

    // MARK: - Progress Fills

    private var exerciseProgressFill: some View {
        GeometryReader { geometry in
            Rectangle()
                .glassEffect(
                    .clear.tint(exerciseTint),
                    in: .rect
                )
                .animation(.easeInOut(duration: 0.5), value: viewModel.state)
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
                    .clear.tint(restTint),
                    in: .rect
                )
                .animation(.easeInOut(duration: 0.5), value: viewModel.state)
                .frame(height: geometry.size.height * viewModel.restProgress)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .scaleEffect(y: -1, anchor: .center)
                .animation(
                    .interpolatingSpring(stiffness: 100, damping: 10),
                    value: viewModel.restProgress
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
            RoutineStep(type: .rest, duration: 3, order: 0),
            RoutineStep(type: .exercise, exerciseId: "pushups", duration: 30, order: 1),
            RoutineStep(type: .rest, exerciseId: "pushups", duration: 15, order: 2),
            RoutineStep(type: .exercise, exerciseId: "pushups", duration: 5, order: 3),
            RoutineStep(type: .exercise, exerciseId: "squats", count: 15, order: 4),
        ])

    RoutinePlayerView(routine: routine)
        .modelContainer(for: [Routine.self, Exercise.self])
}
