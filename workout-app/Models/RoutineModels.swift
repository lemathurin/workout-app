import SwiftData
import Foundation

@Model
class RoutineTranslation {
    var languageCode: String
    var name: String
    var routineDescription: String?
    
    init(languageCode: String, name: String, routineDescription: String? = nil) {
        self.languageCode = languageCode
        self.name = name
        self.routineDescription = routineDescription
    }
}

@Model
class Routine {
    @Attribute(.unique) var id: String
    var translations: [RoutineTranslation]
    var steps: [RoutineStep]
    var metadata: RoutineMetadata
    var isSystemRoutine: Bool
    
    init(translations: [RoutineTranslation], steps: [RoutineStep] = [], isSystemRoutine: Bool = false) {
        self.id = UUID().uuidString
        self.translations = translations
        self.steps = steps
        self.metadata = RoutineMetadata()
        self.isSystemRoutine = isSystemRoutine
    }
    
    // Convenience initializer for user-created routines (single language)
    convenience init(name: String, routineDescription: String? = nil, languageCode: String = "en", steps: [RoutineStep] = []) {
        let translation = RoutineTranslation(languageCode: languageCode, name: name, routineDescription: routineDescription)
        self.init(translations: [translation], steps: steps, isSystemRoutine: false)
    }
    
    // Get localized name
    func getName(for languageCode: String = "en") -> String {
        return translations.first { $0.languageCode == languageCode }?.name 
            ?? translations.first?.name 
            ?? "Unnamed Routine"
    }
    
    // Get localized description
    func getDescription(for languageCode: String = "en") -> String? {
        return translations.first { $0.languageCode == languageCode }?.routineDescription 
            ?? translations.first?.routineDescription
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
}

@Model
class RoutineStep {
    var type: StepType
    var exerciseId: String?
    var duration: Int
    var count: Int?
    var steps: [RoutineStep]?
    var order: Int
    
    init(type: StepType, exerciseId: String? = nil, duration: Int = 0, count: Int? = nil, steps: [RoutineStep]? = nil, order: Int = 0) {
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
}

enum StepType: String, Codable, CaseIterable {
    case exercise = "exercise"
    case rest = "rest"
    case repeats = "repeats"
}

@Model
class RoutineMetadata {
    var createdAt: Date
    var updatedAt: Date
    var categories: [String]
    var difficulty: String
    var tags: [String]
    var equipment: [String]
    var targetMuscles: [String]
    
    init(createdAt: Date = Date(), updatedAt: Date = Date(), categories: [String] = [], difficulty: String = "", tags: [String] = [], equipment: [String] = [], targetMuscles: [String] = []) {
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.categories = categories
        self.difficulty = difficulty
        self.tags = tags
        self.equipment = equipment
        self.targetMuscles = targetMuscles
    }
    
    func updateTimestamp() {
        self.updatedAt = Date()
    }
}
