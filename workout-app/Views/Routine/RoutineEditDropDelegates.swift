import SwiftUI

// MARK: - Item Drop Delegate

struct ItemDropDelegate: DropDelegate {
    @Binding var draggingItem: RepeatItem?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeatId: UUID?
    @Binding var items: [StepItem]
    @Binding var hoveredRepeatId: UUID?
    let targetItem: StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeatId = draggingRepeatId {
                guard let currentIndex = items.firstIndex(where: { $0.id == draggingRepeatId })
                else { return }
                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
                    return
                }

                if currentIndex != targetIndex {
                    items.move(
                        fromOffsets: IndexSet(integer: currentIndex),
                        toOffset: targetIndex > currentIndex ? targetIndex + 1 : targetIndex
                    )
                }
                return
            }

            // Handle dragging individual item
            guard let draggingItem = draggingItem else { return }

            // If dragging from a repeat, don't allow dropping outside
            if draggingFromRepeat != nil {
                if case .repeatGroup = targetItem {
                    return  // Will be handled by RepeatGroupDropDelegate
                } else {
                    return  // Reject drop outside repeat
                }
            }

            // If dragging from a repeat, remove it first
            if let repeatId = draggingFromRepeat {
                RoutineEditHelpers.removeItemFromRepeat(
                    in: &items, repeatId: repeatId, itemId: draggingItem.id)
                draggingFromRepeat = nil

                if let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) {
                    items.insert(
                        RoutineEditHelpers.repeatItemToStepItem(draggingItem), at: targetIndex)
                }
            } else {
                // Moving within main list
                guard let currentIndex = items.firstIndex(where: { $0.id == draggingItem.id })
                else { return }
                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
                    return
                }

                if currentIndex != targetIndex {
                    items.move(
                        fromOffsets: IndexSet(integer: currentIndex),
                        toOffset: targetIndex > currentIndex ? targetIndex + 1 : targetIndex
                    )
                }
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeatId = nil
        hoveredRepeatId = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }

}

// MARK: - Repeat Step Drop Delegate

struct RepeatStepDropDelegate: DropDelegate {
    @Binding var draggingItem: RepeatItem?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeatId: UUID?
    @Binding var items: [StepItem]
    let repeatGroupId: UUID
    let targetItem: RepeatItem

    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }

        // Don't process if we're dragging from the same repeat at the same position
        if let sourceRepeatId = draggingFromRepeat,
            sourceRepeatId == repeatGroupId,
            let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
            case .repeatGroup(_, _, let repeatItems) = items[groupIndex],
            let fromIdx = repeatItems.firstIndex(where: { $0.id == draggingItem.id }),
            let toIdx = repeatItems.firstIndex(where: { $0.id == targetItem.id }),
            fromIdx == toIdx
        {
            return
        }

        withAnimation {
            // Handle moving within same repeat
            if let sourceRepeatId = draggingFromRepeat, sourceRepeatId == repeatGroupId {
                guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                    case .repeatGroup(let id, let count, var repeatItems) = items[groupIndex],
                    let fromIdx = repeatItems.firstIndex(where: { $0.id == draggingItem.id }),
                    let toIdx = repeatItems.firstIndex(where: { $0.id == targetItem.id }),
                    fromIdx != toIdx
                else { return }

                repeatItems.move(
                    fromOffsets: IndexSet(integer: fromIdx),
                    toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
                items[groupIndex] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        // If moving from outside or another repeat, remove from source and insert now
        if let draggingItem = draggingItem, draggingFromRepeat != repeatGroupId {
            // Remove from source
            if let sourceRepeatId = draggingFromRepeat {
                RoutineEditHelpers.removeItemFromRepeat(
                    in: &items, repeatId: sourceRepeatId, itemId: draggingItem.id)
            } else {
                items.removeAll { $0.id == draggingItem.id }
            }

            // Insert into target repeat
            guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                case .repeatGroup(let id, let count, var repeatItems) = items[groupIndex]
            else { return true }

            if let toIdx = repeatItems.firstIndex(where: { $0.id == targetItem.id }) {
                repeatItems.insert(draggingItem, at: toIdx)
            } else {
                repeatItems.append(draggingItem)
            }

            items[groupIndex] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
            self.draggingFromRepeat = repeatGroupId
        }

        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeatId = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }

}

// MARK: - Repeat Group Drop Delegate

struct RepeatGroupDropDelegate: DropDelegate {
    @Binding var draggingItem: RepeatItem?
    @Binding var draggingFromRepeat: UUID?
    @Binding var items: [StepItem]
    @Binding var hoveredRepeatId: UUID?
    let repeatGroupId: UUID

    func dropEntered(info: DropInfo) {
        if draggingFromRepeat != repeatGroupId {
            hoveredRepeatId = repeatGroupId
        }
    }

    func dropExited(info: DropInfo) {
        if hoveredRepeatId == repeatGroupId {
            hoveredRepeatId = nil
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggingItem = draggingItem else { return false }
        if draggingFromRepeat == repeatGroupId { return false }

        withAnimation {
            // Remove from source
            if let sourceRepeatId = draggingFromRepeat {
                RoutineEditHelpers.removeItemFromRepeat(
                    in: &items, repeatId: sourceRepeatId, itemId: draggingItem.id)
            } else {
                items.removeAll { $0.id == draggingItem.id }
            }

            // Add to end of this repeat
            guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                case .repeatGroup(let id, let count, var repeatItems) = items[groupIndex]
            else { return }

            repeatItems.append(draggingItem)
            items[groupIndex] = .repeatGroup(id: id, repeatCount: count, items: repeatItems)
            draggingFromRepeat = repeatGroupId
        }

        self.draggingItem = nil
        self.draggingFromRepeat = nil
        self.hoveredRepeatId = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }

}

// MARK: - Unified Insert Drop Delegate

struct InsertDropDelegate: DropDelegate {
    enum InsertPosition {
        case top
        case before(StepItem)
        case after(StepItem)
        case end
    }

    let position: InsertPosition
    @Binding var draggingItem: RepeatItem?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeatId: UUID?
    @Binding var items: [StepItem]

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeatId = draggingRepeatId {
                guard let currentIndex = items.firstIndex(where: { $0.id == draggingRepeatId })
                else { return }

                let targetIndex = calculateTargetIndex()
                if currentIndex != targetIndex {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: targetIndex)
                }
                return
            }

            // Handle dragging individual item
            guard let draggingItem = draggingItem else { return }

            // If dragging from a repeat, remove it first and convert to StepItem
            if let repeatId = draggingFromRepeat {
                RoutineEditHelpers.removeItemFromRepeat(
                    in: &items, repeatId: repeatId, itemId: draggingItem.id)
                draggingFromRepeat = nil

                let stepItem = RoutineEditHelpers.repeatItemToStepItem(draggingItem)
                let targetIndex = calculateTargetIndex()
                items.insert(stepItem, at: targetIndex)
            } else {
                // Moving within main list
                guard let currentIndex = items.firstIndex(where: { $0.id == draggingItem.id })
                else { return }

                let targetIndex = calculateTargetIndex()

                // Only move if not already at target
                // Note: calculateTargetIndex() already returns the final insertion position
                if currentIndex != targetIndex && targetIndex != currentIndex + 1 {
                    items.move(
                        fromOffsets: IndexSet(integer: currentIndex),
                        toOffset: targetIndex
                    )
                }
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeatId = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        if draggingItem != nil || draggingRepeatId != nil {
            return DropProposal(operation: .move)
        }
        return DropProposal(operation: .forbidden)
    }

    // MARK: - Helpers

    private func calculateTargetIndex() -> Int {
        switch position {
        case .top:
            return 0
        case .before(let targetItem):
            return items.firstIndex(where: { $0.id == targetItem.id }) ?? 0
        case .after(let targetItem):
            if let index = items.firstIndex(where: { $0.id == targetItem.id }) {
                return index + 1
            }
            return items.count
        case .end:
            return items.count
        }
    }
}
