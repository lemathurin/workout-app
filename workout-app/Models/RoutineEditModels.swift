import Foundation

// MARK: - Routine Edit Models

/// Represents an item in the routine editor, either a single step or a repeat group
enum StepItem: Identifiable, Codable, Equatable {
    case step(StepSummary)
    case repeatGroup(RepeatGroup)

    var id: UUID {
        switch self {
        case .step(let s): return s.id
        case .repeatGroup(let r): return r.id
        }
    }
}

/// Summary representation of a step for the routine editor
struct StepSummary: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var mode: StepMode
}

/// A group of steps that repeat multiple times
struct RepeatGroup: Identifiable, Codable, Equatable {
    let id: UUID
    var repeatCount: Int
    var steps: [StepSummary]
}
