import Foundation
import Observation

/// Represents a flattened step for playback, extracted from routine steps (including expanded repeats)
struct PlayableStep: Identifiable, Equatable {
    let id = UUID()
    let exerciseId: String?
    let type: StepType
    let mode: StepMode

    var isRest: Bool { type == .rest }
    var isTimed: Bool {
        switch mode {
        case .exerciseTimed, .restTimed: return true
        case .exerciseReps, .exerciseOpen, .restOpen: return false
        }
    }

    var duration: Int {
        switch mode {
        case .exerciseTimed(let seconds): return seconds
        case .restTimed(let seconds): return seconds
        default: return 0
        }
    }

    var repCount: Int? {
        switch mode {
        case .exerciseReps(let count): return count
        default: return nil
        }
    }
}

/// State of the routine player
enum PlayerState: Equatable {
    case playing
    case paused
    case completed
    case cancelled
}

/// ViewModel for the routine player, managing timer, step progression, and playback state
@Observable
final class RoutinePlayerViewModel {
    // MARK: - Public State

    private(set) var steps: [PlayableStep] = []
    private(set) var currentStepIndex: Int = 0
    private(set) var secondsRemaining: Int = 0
    private(set) var totalStepDuration: Int = 0
    private(set) var exerciseProgress: Double = 0
    private(set) var restProgress: Double = 0
    private(set) var state: PlayerState = .playing

    var currentStep: PlayableStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var progress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(currentStepIndex) / Double(steps.count)
    }

    var isLastStep: Bool {
        currentStepIndex == steps.count - 1
    }

    var timerProgress: Double {
        guard totalStepDuration > 0 else { return 0 }
        return 1.0 - Double(secondsRemaining) / Double(totalStepDuration)
    }

    // MARK: - Private State

    private var timerTask: Task<Void, Never>?

    // MARK: - Initialization

    init(routine: Routine) {
        self.steps = flattenSteps(routine.steps.sorted { $0.order < $1.order })
        beginCurrentStep()
    }

    deinit {
        timerTask?.cancel()
    }

    // MARK: - Public Methods

    func togglePause() {
        if state == .playing {
            pauseTimer()
            state = .paused
        } else if state == .paused {
            state = .playing
            if currentStep?.isTimed == true {
                startTimer()
            }
        }
    }

    func completeCurrentStep() {
        timerTask?.cancel()
        advanceToNextStep()
    }

    func goToPreviousStep() {
        guard currentStepIndex > 0 else { return }
        timerTask?.cancel()
        currentStepIndex -= 1
        state = .playing
        beginCurrentStep()
    }

    func cancelRoutine() {
        timerTask?.cancel()
        state = .cancelled
    }

    func restart() {
        timerTask?.cancel()
        currentStepIndex = 0
        state = .playing
        beginCurrentStep()
    }

    // MARK: - Private Methods

    private func beginCurrentStep() {
    guard let step = currentStep else {
        state = .completed
        return
    }

    exerciseProgress = 0
    restProgress = 0

    if step.isTimed {
        secondsRemaining = step.duration
        totalStepDuration = step.duration
        if state == .playing {
            updateActiveProgress()
            startTimer()
        }
    } else {
        secondsRemaining = 0
        totalStepDuration = 0
    }
}

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while let self = self,
                self.state == .playing,
                self.secondsRemaining > 0
            {
                do {
                    try await Task.sleep(for: .seconds(1))
                    if self.state == .playing {
                        self.secondsRemaining -= 1
                        self.updateActiveProgress()
                        if self.secondsRemaining == 0 {
                            self.advanceToNextStep()
                        }
                    }
                } catch {
                    break
                }
            }
        }
    }

    private func updateActiveProgress() {
        if currentStep?.isRest == true {
            restProgress = timerProgress
        } else {
            exerciseProgress = timerProgress
        }
    }

    private func pauseTimer() {
        timerTask?.cancel()
    }

    private func advanceToNextStep() {
    // Snap progress to full before moving on
    if currentStep?.isRest == true {
        restProgress = 1.0
    } else {
        exerciseProgress = 1.0
    }

    Task { @MainActor in
        // Brief delay so the fill animation can complete visually
        try? await Task.sleep(for: .milliseconds(400))
        
        if currentStepIndex < steps.count - 1 {
            currentStepIndex += 1
            beginCurrentStep()
        } else {
            exerciseProgress = 0
            restProgress = 0
            state = .completed
        }
    }
}

    // MARK: - Step Flattening

    private func flattenSteps(_ routineSteps: [RoutineStep]) -> [PlayableStep] {
        var result: [PlayableStep] = []

        for step in routineSteps {
            switch step.type {
            case .exercise:
                result.append(
                    PlayableStep(
                        exerciseId: step.exerciseId,
                        type: .exercise,
                        mode: stepToMode(step)
                    ))
            case .rest:
                result.append(
                    PlayableStep(
                        exerciseId: nil,
                        type: .rest,
                        mode: stepToMode(step)
                    ))
            case .repeats:
                guard let repeatCount = step.count,
                    let nestedSteps = step.steps
                else { continue }

                let sortedNested = nestedSteps.sorted { $0.order < $1.order }
                for _ in 0..<repeatCount {
                    result.append(contentsOf: flattenSteps(sortedNested))
                }
            }
        }

        return result
    }

    private func stepToMode(_ step: RoutineStep) -> StepMode {
        switch step.type {
        case .exercise:
            if step.duration > 0 {
                return .exerciseTimed(seconds: step.duration)
            } else if let count = step.count, count > 0 {
                return .exerciseReps(count: count)
            } else {
                return .exerciseOpen
            }
        case .rest:
            if step.duration > 0 {
                return .restTimed(seconds: step.duration)
            } else {
                return .restOpen
            }
        case .repeats:
            return .exerciseOpen
        }
    }
}
