import Foundation

// MARK: - Routine Edit Models (Enum-Driven, Single Source of Truth)

/// Represents an item in the routine editor
/// The enum case itself determines what type of item it is (exercise, rest, or repeat)
enum StepItem: Identifiable, Codable, Equatable {
    case exercise(id: UUID, exerciseId: String, name: String, mode: ExerciseStepMode)
    case rest(id: UUID, mode: RestStepMode)
    case repeatGroup(id: UUID, repeatCount: Int, items: [RepeatItem])

    var id: UUID {
        switch self {
        case .exercise(let id, _, _, _): return id
        case .rest(let id, _): return id
        case .repeatGroup(let id, _, _): return id
        }
    }
}

/// Modes available for exercise steps
enum ExerciseStepMode: Codable, Equatable {
    case timed(seconds: Int)
    case reps(count: Int)
    case open
}

/// Modes available for rest steps
enum RestStepMode: Codable, Equatable {
    case timed(seconds: Int)
    case open
}

/// Items that can exist within a repeat group
enum RepeatItem: Identifiable, Codable, Equatable {
    case exercise(id: UUID, exerciseId: String, name: String, mode: ExerciseStepMode)
    case rest(id: UUID, mode: RestStepMode)

    var id: UUID {
        switch self {
        case .exercise(let id, _, _, _): return id
        case .rest(let id, _): return id
        }
    }
}

// MARK: - Helper Extensions

extension StepItem {
    /// Display name for UI (always "Rest" for rest items)
    var displayName: String {
        switch self {
        case .exercise(_, _, let name, _):
            return name
        case .rest:
            return "Rest"
        case .repeatGroup:
            return "Repeat Group"
        }
    }

    /// Check if this is a rest step
    var isRest: Bool {
        if case .rest = self { return true }
        return false
    }

    /// Check if this is an exercise step
    var isExercise: Bool {
        if case .exercise = self { return true }
        return false
    }
}

extension RepeatItem {
    /// Display name for UI
    var displayName: String {
        switch self {
        case .exercise(_, _, let name, _):
            return name
        case .rest:
            return "Rest"
        }
    }

    /// Check if this is a rest step
    var isRest: Bool {
        if case .rest = self { return true }
        return false
    }
}
