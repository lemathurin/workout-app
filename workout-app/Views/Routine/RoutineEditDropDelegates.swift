import SwiftUI

// MARK: - Item Drop Delegate

struct ItemDropDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RepeatGroup?
    @Binding var items: [StepItem]
    @Binding var hoveredRepeatId: UUID?
    let targetItem: StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                            return true
                        }
                        return false
                    })
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

            // Handle dragging individual step
            guard let draggingItem = draggingItem else { return }

            // If dragging from a repeat, don't allow dropping outside - only allow dropping on other repeats
            if draggingFromRepeat != nil {
                // Only allow if target is a repeat group
                if case .repeatGroup = targetItem {
                    // This will be handled by RepeatGroupDropDelegate
                    return
                } else {
                    // Reject drop outside repeat
                    return
                }
            }

            // If dragging from a repeat, remove it first and clear the flag
            if let repeatId = draggingFromRepeat {
                removeStepFromRepeat(repeatId: repeatId, stepId: draggingItem.id)
                draggingFromRepeat = nil

                // Insert at target position
                if let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) {
                    items.insert(.step(draggingItem), at: targetIndex)
                }
            } else {
                // Moving within main list
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .step(let s) = item, s.id == draggingItem.id {
                            return true
                        }
                        return false
                    })
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
        draggingRepeat = nil
        hoveredRepeatId = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}

// MARK: - Repeat Step Drop Delegate

struct RepeatStepDropDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RepeatGroup?
    @Binding var items: [StepItem]
    let repeatGroupId: UUID
    let targetStep: StepSummary

    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }

        // Don't process if we're dragging from the same repeat and at the same position
        if let sourceRepeatId = draggingFromRepeat,
            sourceRepeatId == repeatGroupId,
            let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
            case .repeatGroup(let group) = items[groupIndex],
            let fromIdx = group.steps.firstIndex(where: { $0.id == draggingItem.id }),
            let toIdx = group.steps.firstIndex(where: { $0.id == targetStep.id }),
            fromIdx == toIdx
        {
            return
        }

        withAnimation {
            // Handle moving within same repeat
            if let sourceRepeatId = draggingFromRepeat, sourceRepeatId == repeatGroupId {
                guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                    case .repeatGroup(var group) = items[groupIndex],
                    let fromIdx = group.steps.firstIndex(where: { $0.id == draggingItem.id }),
                    let toIdx = group.steps.firstIndex(where: { $0.id == targetStep.id }),
                    fromIdx != toIdx
                else { return }

                group.steps.move(
                    fromOffsets: IndexSet(integer: fromIdx),
                    toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
                items[groupIndex] = .repeatGroup(group)
            } else {
                // Moving from outside or another repeat into this repeat
                // Removal and insertion will happen in performDrop
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        // If moving from outside or another repeat, remove from source and insert now
        if let draggingItem = draggingItem, draggingFromRepeat != repeatGroupId {
            // Remove from source
            if let sourceRepeatId = draggingFromRepeat {
                removeStepFromRepeat(repeatId: sourceRepeatId, stepId: draggingItem.id)
            } else {
                items.removeAll { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }
            }

            // Insert into target repeat
            guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                case .repeatGroup(var group) = items[groupIndex]
            else { return true }

            if let toIdx = group.steps.firstIndex(where: { $0.id == targetStep.id }) {
                group.steps.insert(draggingItem, at: toIdx)
            } else {
                group.steps.append(draggingItem)
            }

            items[groupIndex] = .repeatGroup(group)
            self.draggingFromRepeat = repeatGroupId
        }

        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeat = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}

// MARK: - Repeat Group Drop Delegate

struct RepeatGroupDropDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var items: [StepItem]
    @Binding var hoveredRepeatId: UUID?
    let repeatGroupId: UUID

    func dropEntered(info: DropInfo) {
        // Don't highlight if dragging from the same repeat group
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

        // Don't perform drop if dragging from the same repeat group
        if draggingFromRepeat == repeatGroupId { return false }

        withAnimation {
            // Remove from source
            if let sourceRepeatId = draggingFromRepeat {
                removeStepFromRepeat(repeatId: sourceRepeatId, stepId: draggingItem.id)
            } else {
                items.removeAll { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }
            }

            // Add to end of this repeat
            guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                case .repeatGroup(var group) = items[groupIndex]
            else { return }

            group.steps.append(draggingItem)
            items[groupIndex] = .repeatGroup(group)
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

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}

// MARK: - Insert At Top Delegate

struct InsertAtTopDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RepeatGroup?
    @Binding var items: [StepItem]

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                            return true
                        }
                        return false
                    })
                else { return }

                if currentIndex != 0 {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: 0)
                }
                return
            }

            // Handle dragging individual step
            guard let draggingItem = draggingItem else { return }

            if let repeatId = draggingFromRepeat {
                // Remove from repeat and insert at top
                removeStepFromRepeat(repeatId: repeatId, stepId: draggingItem.id)
                draggingFromRepeat = nil

                items.insert(.step(draggingItem), at: 0)
            } else {
                // Move within main list
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .step(let s) = item, s.id == draggingItem.id {
                            return true
                        }
                        return false
                    })
                else { return }

                if currentIndex != 0 {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: 0)
                }
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeat = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        if draggingItem != nil || draggingRepeat != nil {
            return DropProposal(operation: .move)
        }
        return DropProposal(operation: .forbidden)
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}

// MARK: - Insert Before Drop Delegate

struct InsertBeforeDropDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RepeatGroup?
    @Binding var items: [StepItem]
    let targetItem: StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                            return true
                        }
                        return false
                    })
                else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
                    return
                }

                if currentIndex != targetIndex {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: targetIndex)
                }
                return
            }

            // Handle dragging individual step
            guard let draggingItem = draggingItem else { return }

            if let repeatId = draggingFromRepeat {
                // Remove from repeat and insert before target
                removeStepFromRepeat(repeatId: repeatId, stepId: draggingItem.id)
                draggingFromRepeat = nil

                if let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) {
                    items.insert(.step(draggingItem), at: targetIndex)
                }
            } else {
                // Move within main list
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .step(let s) = item, s.id == draggingItem.id {
                            return true
                        }
                        return false
                    })
                else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
                    return
                }

                if currentIndex != targetIndex {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: targetIndex)
                }
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeat = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        if draggingItem != nil || draggingRepeat != nil {
            return DropProposal(operation: .move)
        }
        return DropProposal(operation: .forbidden)
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}

// MARK: - Insert After Drop Delegate

struct InsertAfterDropDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RepeatGroup?
    @Binding var items: [StepItem]
    let targetItem: StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                            return true
                        }
                        return false
                    })
                else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
                    return
                }

                let newIndex = targetIndex + 1
                if currentIndex != newIndex {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: newIndex)
                }
                return
            }

            // Handle dragging individual step
            guard let draggingItem = draggingItem else { return }

            if let repeatId = draggingFromRepeat {
                // Remove from repeat and insert after target
                removeStepFromRepeat(repeatId: repeatId, stepId: draggingItem.id)
                draggingFromRepeat = nil

                if let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) {
                    items.insert(.step(draggingItem), at: targetIndex + 1)
                }
            } else {
                // Move within main list
                guard
                    let currentIndex = items.firstIndex(where: { item in
                        if case .step(let s) = item, s.id == draggingItem.id {
                            return true
                        }
                        return false
                    })
                else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else {
                    return
                }

                let newIndex = targetIndex + 1
                if currentIndex != newIndex {
                    items.move(fromOffsets: IndexSet(integer: currentIndex), toOffset: newIndex)
                }
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        draggingFromRepeat = nil
        draggingRepeat = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        if draggingItem != nil || draggingRepeat != nil {
            return DropProposal(operation: .move)
        }
        return DropProposal(operation: .forbidden)
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}

// MARK: - End Drop Delegate

struct EndDropDelegate: DropDelegate {
    @Binding var draggingItem: StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RepeatGroup?
    @Binding var items: [StepItem]

    func performDrop(info: DropInfo) -> Bool {
        withAnimation {
            // Handle dragging entire repeat
            if let draggingRepeat = draggingRepeat {
                if case .repeatGroup(let lastRepeat) = items.last,
                    lastRepeat.id == draggingRepeat.id
                {
                    self.draggingRepeat = nil
                    return true
                }

                items.removeAll { item in
                    if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                        return true
                    }
                    return false
                }

                items.append(.repeatGroup(draggingRepeat))
                self.draggingRepeat = nil
                return true
            }

            // Handle dragging step
            guard let draggingItem = draggingItem else { return false }

            // If dragging from a repeat, don't allow dropping at the end
            if draggingFromRepeat != nil {
                self.draggingItem = nil
                self.draggingFromRepeat = nil
                return false
            }

            // Check if already at the end
            if case .step(let lastStep) = items.last, lastStep.id == draggingItem.id {
                self.draggingItem = nil
                self.draggingFromRepeat = nil
                return true
            }

            // Remove from source
            if let repeatId = draggingFromRepeat {
                removeStepFromRepeat(repeatId: repeatId, stepId: draggingItem.id)
            } else {
                items.removeAll { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }
            }

            // Add to end
            items.append(.step(draggingItem))

            self.draggingItem = nil
            self.draggingFromRepeat = nil
            return true
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
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
}
