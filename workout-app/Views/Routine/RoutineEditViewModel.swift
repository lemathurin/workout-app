import Observation
import SwiftUI

/// ViewModel for RoutineEditView that manages all state and business logic
@Observable
class RoutineEditViewModel {
    // MARK: - State Properties

    var items: [StepItem] = []

    // Drag state
    var draggingItem: StepSummary? = nil
    var draggingFromRepeat: UUID? = nil
    var draggingRepeat: RepeatGroup? = nil
    var hoveredRepeatId: UUID? = nil

    // Editing state
    var editingStepId: UUID? = nil
    var editingRepeatId: UUID? = nil
    var editAction: StepEditAction? = nil

    // Sheet state
    var sheetDetent: PresentationDetent = .medium
    var editingRepeatCountId: UUID? = nil
    var repeatCountSheetDetent: PresentationDetent = .medium
    var showNewStepSheet: Bool = false
    var newStepSheetDetent: PresentationDetent = .medium

    // MARK: - Computed Properties

    var isEditingStep: Bool {
        editingStepId != nil && editAction != nil
    }

    var isEditingRepeatCount: Bool {
        editingRepeatCountId != nil
    }

    // MARK: - Business Logic Methods

    func updateRepeatCount(repeatId: UUID, newCount: Int) {
        if let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(var group) = items[index]
        {
            group.repeatCount = newCount
            items[index] = .repeatGroup(group)
        }
    }

    func updateTopLevelStep(stepId: UUID, newMode: StepMode) {
        if let index = items.firstIndex(where: { $0.id == stepId }),
            case .step(var step) = items[index]
        {
            step.mode = newMode
            items[index] = .step(step)
        }
    }

    func updateStepInRepeat(repeatId: UUID, stepId: UUID, newMode: StepMode) {
        if let repeatIndex = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(var group) = items[repeatIndex],
            let stepIndex = group.steps.firstIndex(where: { $0.id == stepId })
        {
            group.steps[stepIndex].mode = newMode
            items[repeatIndex] = .repeatGroup(group)
        }
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(var group) = items[index]
        else { return }

        group.steps.removeAll { $0.id == stepId }

        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }

    func moveStepOutOfRepeat(repeatId: UUID, stepId: UUID) {
        guard let repeatIndex = items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(var group) = items[repeatIndex],
            let stepIndex = group.steps.firstIndex(where: { $0.id == stepId })
        else { return }

        let step = group.steps.remove(at: stepIndex)

        if group.steps.isEmpty {
            items.remove(at: repeatIndex)
        } else {
            items[repeatIndex] = .repeatGroup(group)
        }

        // Insert after the repeat group
        let insertIndex = repeatIndex + (group.steps.isEmpty ? 0 : 1)
        items.insert(.step(step), at: insertIndex)
    }

    // MARK: - Action Handlers

    func handleStepEdit(stepId: UUID, repeatId: UUID?, action: StepEditAction) {
        editingStepId = stepId
        editingRepeatId = repeatId
        editAction = action
    }

    func handleRepeatCountEdit(repeatId: UUID) {
        editingRepeatCountId = repeatId
    }

    func handleAddStep(name: String?, mode: StepMode) {
        let newStep = StepSummary(id: UUID(), name: name ?? "", mode: mode)
        items.append(.step(newStep))
        showNewStepSheet = false
    }

    func handleStartRepeatFlow() {
        let newRepeatGroup = RepeatGroup(id: UUID(), repeatCount: 2, steps: [])
        items.append(.repeatGroup(newRepeatGroup))
        showNewStepSheet = false
    }

    func closeEditSheet() {
        editingStepId = nil
        editAction = nil
    }

    func closeRepeatCountSheet() {
        editingRepeatCountId = nil
    }
}
