import SwiftUI

/// Shared helper functions for drag-and-drop operations in the routine editor
enum RoutineEditHelpers {

    // MARK: - Item Manipulation

    /// Remove an item from a repeat group, handling empty group deletion
    static func removeItemFromRepeat(in items: inout [StepItem], repeatId: UUID, itemId: UUID) {
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

    /// Convert a RepeatItem to a StepItem
    static func repeatItemToStepItem(_ item: RepeatItem) -> StepItem {
        switch item {
        case .exercise(let id, let exerciseId, let name, let mode):
            return .exercise(id: id, exerciseId: exerciseId, name: name, mode: mode)
        case .rest(let id, let mode):
            return .rest(id: id, mode: mode)
        }
    }

    /// Reset all drag state bindings
    static func resetDragState(
        draggingItem: inout RepeatItem?,
        draggingFromRepeat: inout UUID?,
        draggingRepeatId: inout UUID?,
        hoveredRepeatId: inout UUID?
    ) {
        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeatId = nil
        hoveredRepeatId = nil
    }

    // MARK: - Validation

    /// Check if a step can be dropped outside of a repeat group
    /// Rule: Steps cannot be dragged out of repeat groups
    static func canDropStepOutsideRepeat(draggingFromRepeat: UUID?) -> Bool {
        return draggingFromRepeat == nil
    }

    /// Check if a repeat can be dropped into another repeat
    /// Rule: Repeat groups cannot be nested
    static func canDropRepeatIntoRepeat(targetItem: StepItem) -> Bool {
        if case .repeatGroup = targetItem {
            return false
        }
        return true
    }

    // MARK: - Movement Operations

    /// Move an item within the items array from one index to another
    static func moveItem(from fromIndex: Int, to toIndex: Int, in items: inout [StepItem]) {
        guard fromIndex != toIndex else { return }
        items.move(
            fromOffsets: IndexSet(integer: fromIndex),
            toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
        )
    }

    /// Calculate the target index for insertion based on current and target positions
    static func calculateInsertIndex(
        currentIndex: Int,
        targetIndex: Int,
        before: Bool
    ) -> Int {
        if before {
            return targetIndex
        } else {
            return targetIndex + 1
        }
    }
}
