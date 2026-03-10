import SwiftData
import SwiftUI

struct RoutinePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    @State private var viewModel: RoutinePlayerViewModel

    let routine: Routine

    init(routine: Routine) {
        self.routine = routine
        _viewModel = State(initialValue: RoutinePlayerViewModel(routine: routine))
    }

    var body: some View {
        ZStack {
            backgroundGradient

            switch viewModel.state {
            case .playing, .paused:
                playerContent
            case .completed:
                completionContent
            case .cancelled:
                EmptyView()
            }
        }
        .onChange(of: viewModel.state) { _, newState in
            if newState == .cancelled {
                dismiss()
            }
        }
    }

    // MARK: - Player Content

    private var playerContent: some View {
        VStack(spacing: 32) {
            headerSection

            Spacer()

            stepDisplaySection

            Spacer()

            controlsSection
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button("Cancel", systemImage: "xmark") {
                    viewModel.cancelRoutine()
                }
                .font(.body)
                .foregroundStyle(.secondary)

                Spacer()

                Text("Step \(viewModel.currentStepIndex + 1) of \(viewModel.steps.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: viewModel.progress)
                .tint(.green)
        }
    }

    // MARK: - Step Display Section

    private var stepDisplaySection: some View {
        VStack(spacing: 24) {
            if let step = viewModel.currentStep {
                // Step type indicator
                Image(systemName: step.isRest ? "pause.circle.fill" : "figure.run")
                    .font(.system(size: 48))
                    .foregroundStyle(step.isRest ? .blue : .green)

                // Step name
                Text(stepName(for: step))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel(step.isRest ? "Rest" : stepName(for: step))

                // Mode-specific display
                stepModeDisplay(for: step)
            }
        }
    }

    @ViewBuilder
    private func stepModeDisplay(for step: PlayableStep) -> some View {
        switch step.mode {
        case .exerciseTimed, .restTimed:
            CountdownDisplayView(seconds: viewModel.secondsRemaining)
        case .exerciseReps(let count):
            VStack(spacing: 8) {
                Text("\(count)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("reps")
                    .font(.title2)
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

    // MARK: - Controls Section

    private var controlsSection: some View {
        VStack(spacing: 16) {
            if let step = viewModel.currentStep {
                if step.isTimed {
                    // Timed steps: pause/resume button
                    Button {
                        viewModel.togglePause()
                    } label: {
                        Label(
                            viewModel.state == .paused ? "Resume" : "Pause",
                            systemImage: viewModel.state == .paused ? "play.fill" : "pause.fill"
                        )
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .accessibilityHint(
                        "Tap to \(viewModel.state == .paused ? "resume" : "pause") the timer")

                    // Skip button for timed steps
                    Button {
                        viewModel.completeCurrentStep()
                    } label: {
                        Text("Skip")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Skip this step")
                } else {
                    // Reps/Open steps: done button
                    Button {
                        viewModel.completeCurrentStep()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .accessibilityHint("Tap when you have completed this step")
                }
            }
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
            .padding(.bottom, 40)
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(UIColor.systemBackground),
                Color(UIColor.secondarySystemBackground),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
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
            .font(.system(size: 96, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.primary)
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
            RoutineStep(type: .exercise, exerciseId: "pushups", duration: 30, order: 0),
            RoutineStep(type: .rest, duration: 10, order: 1),
            RoutineStep(type: .exercise, exerciseId: "squats", count: 15, order: 2),
        ])

    RoutinePlayerView(routine: routine)
        .modelContainer(for: [Routine.self, Exercise.self])
}
