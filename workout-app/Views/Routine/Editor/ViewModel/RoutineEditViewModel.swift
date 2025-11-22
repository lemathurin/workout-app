import Observation
import SwiftUI

/// ViewModel for RoutineEditView that manages all state and business logic
@Observable
class RoutineEditViewModel {
    // MARK: - State Properties

    var routineName: String = ""
    var items: [StepItem] = []

    // Drag state
    var draggingItem: RepeatItem? = nil
    var draggingFromRepeat: UUID? = nil
    var draggingRepeatId: UUID? = nil
    var hoveredRepeatId: UUID? = nil

    // Editing state
    var editingItemId: UUID? = nil
    var editingRepeatId: UUID? = nil
    var editAction: StepEditAction? = nil

    // Sheet state
    var sheetDetent: PresentationDetent = .medium
    var editingRepeatCountId: UUID? = nil
    var repeatCountSheetDetent: PresentationDetent = .medium
    var showNewStepSheet: Bool = false
    var newStepSheetDetent: PresentationDetent = .height(300)

    // MARK: - Computed Properties

    var isEditingStep: Bool {
        editingItemId != nil && editAction != nil
    }

    var isEditingRepeatCount: Bool {
        editingRepeatCountId != nil
    }

    // MARK: - Update Methods

    func updateRepeatCount(repeatId: UUID, newCount: Int) {
        if let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let id, _, let items) = items[index]
        {
            self.items[index] = .repeatGroup(id: id, repeatCount: newCount, items: items)
        }
    }

    func updateExerciseMode(id: UUID, newMode: ExerciseStepMode) {
        if let index = items.firstIndex(where: { $0.id == id }),
            case .exercise(let itemId, let exerciseId, let name, _) = items[index]
        {
            items[index] = .exercise(id: itemId, exerciseId: exerciseId, name: name, mode: newMode)
        }
    }

    func updateRestMode(id: UUID, newMode: RestStepMode) {
        if let index = items.firstIndex(where: { $0.id == id }),
            case .rest(let itemId, _) = items[index]
        {
            items[index] = .rest(id: itemId, mode: newMode)
        }
    }

    func updateExerciseInRepeat(repeatId: UUID, exerciseId: UUID, newMode: ExerciseStepMode) {
        if let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let id, let count, var repeatItems) = items[index],
            let itemIndex = repeatItems.firstIndex(where: { $0.id == exerciseId }),
            case .exercise(let exId, let exExerciseId, let name, _) = repeatItems[itemIndex]
        {
            repeatItems[itemIndex] = .exercise(
                id: exId, exerciseId: exExerciseId, name: name, mode: newMode)
            items[index] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
        }
    }

    func updateRestInRepeat(repeatId: UUID, restId: UUID, newMode: RestStepMode) {
        if let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let id, let count, var repeatItems) = items[index],
            let itemIndex = repeatItems.firstIndex(where: { $0.id == restId }),
            case .rest(let restItemId, _) = repeatItems[itemIndex]
        {
            repeatItems[itemIndex] = .rest(id: restItemId, mode: newMode)
            items[index] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
        }
    }

    // MARK: - CRUD Methods

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    func removeItemFromRepeat(repeatId: UUID, itemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let id, let count, var repeatItems) = items[index]
        else { return }

        repeatItems.removeAll { $0.id == itemId }

        if repeatItems.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
        }
    }

    func moveItemOutOfRepeat(repeatId: UUID, itemId: UUID) {
        guard let repeatIndex = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let id, let count, var repeatItems) = items[repeatIndex],
            let itemIndex = repeatItems.firstIndex(where: { $0.id == itemId })
        else { return }

        let item = repeatItems.remove(at: itemIndex)

        // Update or remove the repeat group
        if repeatItems.isEmpty {
            items.remove(at: repeatIndex)
        } else {
            items[repeatIndex] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
        }

        // Convert RepeatItem to StepItem
        let stepItem: StepItem
        switch item {
        case .exercise(let id, let exerciseId, let name, let mode):
            stepItem = .exercise(id: id, exerciseId: exerciseId, name: name, mode: mode)
        case .rest(let id, let mode):
            stepItem = .rest(id: id, mode: mode)
        }

        let insertIndex = repeatIndex + (repeatItems.isEmpty ? 0 : 1)
        items.insert(stepItem, at: insertIndex)
    }

    // MARK: - Action Handlers

    func handleStepEdit(itemId: UUID, repeatId: UUID?, action: StepEditAction) {
        editingItemId = itemId
        editingRepeatId = repeatId
        editAction = action
    }

    func handleRepeatCountEdit(repeatId: UUID) {
        editingRepeatCountId = repeatId
    }

    func handleAddExercise(exerciseId: String, name: String, mode: ExerciseStepMode) {
        items.append(.exercise(id: UUID(), exerciseId: exerciseId, name: name, mode: mode))
        showNewStepSheet = false
    }

    func handleAddRest(mode: RestStepMode) {
        items.append(.rest(id: UUID(), mode: mode))
        showNewStepSheet = false
    }

    func handleStartRepeatFlow(count: Int) {
        items.append(.repeatGroup(id: UUID(), repeatCount: count, items: []))
        showNewStepSheet = false
    }

    // MARK: - Duplicate Methods

    func duplicateStep(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }

        let duplicatedItem: StepItem
        switch items[index] {
        case .exercise(_, let exerciseId, let name, let mode):
            duplicatedItem = .exercise(id: UUID(), exerciseId: exerciseId, name: name, mode: mode)
        case .rest(_, let mode):
            duplicatedItem = .rest(id: UUID(), mode: mode)
        case .repeatGroup:
            return  // Use duplicateRepeatGroup for repeat groups
        }

        items.insert(duplicatedItem, at: index + 1)
    }

    func duplicateStepInRepeat(repeatId: UUID, itemId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let id, let count, var repeatItems) = items[index],
            let itemIndex = repeatItems.firstIndex(where: { $0.id == itemId })
        else { return }

        let duplicatedItem: RepeatItem
        switch repeatItems[itemIndex] {
        case .exercise(_, let exerciseId, let name, let mode):
            duplicatedItem = .exercise(id: UUID(), exerciseId: exerciseId, name: name, mode: mode)
        case .rest(_, let mode):
            duplicatedItem = .rest(id: UUID(), mode: mode)
        }

        repeatItems.insert(duplicatedItem, at: itemIndex + 1)
        items[index] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
    }

    func duplicateRepeatGroup(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }),
            case .repeatGroup(_, let count, let repeatItems) = items[index]
        else { return }

        // Create new items with new UUIDs
        let duplicatedItems: [RepeatItem] = repeatItems.map { item in
            switch item {
            case .exercise(_, let exerciseId, let name, let mode):
                return .exercise(id: UUID(), exerciseId: exerciseId, name: name, mode: mode)
            case .rest(_, let mode):
                return .rest(id: UUID(), mode: mode)
            }
        }

        let duplicatedGroup = StepItem.repeatGroup(
            id: UUID(),
            repeatCount: count,
            items: duplicatedItems
        )

        items.insert(duplicatedGroup, at: index + 1)
    }

    func closeEditSheet() {
        editingItemId = nil
        editAction = nil
    }

    func closeRepeatCountSheet() {
        editingRepeatCountId = nil
    }
}
