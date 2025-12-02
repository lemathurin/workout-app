import Foundation
import SwiftData

@Model
class RoutineTranslation {
    var languageCode: String
    var name: String

    init(languageCode: String, name: String) {
        self.languageCode = languageCode
        self.name = name
    }
}

@Model
class Routine {
    @Attribute(.unique) var id: String
    var translations: [RoutineTranslation]
    var steps: [RoutineStep]
    var metadata: RoutineMetadata
    var isSystemRoutine: Bool

    init(
        translations: [RoutineTranslation], steps: [RoutineStep] = [], isSystemRoutine: Bool = false
    ) {
        self.id = UUID().uuidString
        self.translations = translations
        self.steps = steps
        self.metadata = RoutineMetadata()
        self.isSystemRoutine = isSystemRoutine
    }

    // Convenience initializer for user-created routines (single language)
    convenience init(name: String, languageCode: String = "en", steps: [RoutineStep] = []) {
        let translation = RoutineTranslation(languageCode: languageCode, name: name)
        self.init(translations: [translation], steps: steps, isSystemRoutine: false)
    }

    // Get localized name
    func getName(for languageCode: String = "en") -> String {
        return translations.first { $0.languageCode == languageCode }?.name
            ?? translations.first?.name
            ?? "Unnamed Routine"
    }

    /// Calculates total duration by traversing all steps including nested repeats
    func calculateTotalDuration() -> Int {
        return steps.reduce(0) { total, step in
            total + step.calculateDuration()
        }
    }

    /// Counts total number of exercise steps (excluding rest and repeat containers)
    func calculateExerciseCount() -> Int {
        return steps.reduce(0) { total, step in
            total + step.countExercises()
        }
    }

    /// Counts total number of all steps (exercises, rests, and repeat contents)
    func calculateStepCount() -> Int {
        return steps.reduce(0) { total, step in
            total + step.countSteps()
        }
    }

    /// Updates metadata with current step count and duration
    func updateMetadata() {
        metadata.stepCount = calculateStepCount()
        metadata.totalDuration = calculateTotalDuration()
        metadata.updateTimestamp()
    }
}

@Model
class RoutineStep {
    var type: StepType
    var exerciseId: String?
    var duration: Int
    var count: Int?
    var steps: [RoutineStep]?
    var order: Int

    init(
        type: StepType, exerciseId: String? = nil, duration: Int = 0, count: Int? = nil,
        steps: [RoutineStep]? = nil, order: Int = 0
    ) {
        self.type = type
        self.exerciseId = exerciseId
        self.duration = duration
        self.count = count
        self.steps = steps
        self.order = order
    }

    /// Calculates duration for this step, including nested steps for repeats
    func calculateDuration() -> Int {
        switch type {
        case .exercise, .rest:
            return duration
        case .repeats:
            guard let count = count, let steps = steps else { return 0 }
            let stepsDuration = steps.reduce(0) { $0 + $1.calculateDuration() }
            return stepsDuration * count
        }
    }

    /// Counts exercise steps in this step and nested steps
    func countExercises() -> Int {
        switch type {
        case .exercise:
            return 1
        case .rest:
            return 0
        case .repeats:
            guard let count = count, let steps = steps else { return 0 }
            let stepsExerciseCount = steps.reduce(0) { $0 + $1.countExercises() }
            return stepsExerciseCount * count
        }
    }

    /// Counts all steps (exercises, rests, and repeat contents) in this step and nested steps
    func countSteps() -> Int {
        switch type {
        case .exercise, .rest:
            return 1
        case .repeats:
            guard let count = count, let steps = steps else { return 0 }
            let nestedStepCount = steps.reduce(0) { $0 + $1.countSteps() }
            return nestedStepCount * count
        }
    }
}

enum StepType: String, Codable, CaseIterable {
    case exercise = "exercise"
    case rest = "rest"
    case repeats = "repeats"
}

/// Semantic representation of a step's type and mode.
/// Captures both the category (exercise/rest) AND the mode (timed/reps/open) with associated values.
///
/// Example usage:
/// ```
/// let timedExercise = StepMode.exerciseTimed(seconds: 30)
/// let restWithDuration = StepMode.restTimed(seconds: 60)
/// let repsExercise = StepMode.exerciseReps(count: 10)
/// ```
enum StepMode: Codable, Equatable {
    case exerciseTimed(seconds: Int)
    case exerciseReps(count: Int)
    case exerciseOpen
    case restTimed(seconds: Int)
    case restOpen
}

// Exercise and Rest mode variants for editing logic
enum ExerciseMode { case timed, reps, open }
enum RestMode { case timed, open }

@Model
class RoutineMetadata {
    var createdAt: Date
    var updatedAt: Date
    var categories: [String]
    var difficulty: String
    var tags: [String]
    var equipment: [String]
    var targetMuscles: [String]
    var author: String?
    var stepCount: Int?
    var totalDuration: Int?

    init(
        createdAt: Date = Date(), updatedAt: Date = Date(), categories: [String] = [],
        difficulty: String = "", tags: [String] = [], equipment: [String] = [],
        targetMuscles: [String] = [], author: String? = nil, stepCount: Int? = nil,
        totalDuration: Int? = nil
    ) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.categories = categories
        self.difficulty = difficulty
        self.tags = tags
        self.equipment = equipment
        self.targetMuscles = targetMuscles
        self.author = author
        self.stepCount = stepCount
        self.totalDuration = totalDuration
    }

    func updateTimestamp() {
        self.updatedAt = Date()
    }
}
