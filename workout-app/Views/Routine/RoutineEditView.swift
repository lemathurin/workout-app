import SwiftUI
import UniformTypeIdentifiers

struct RoutineEditView: View {
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
    
    struct StepSummary: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var mode: StepMode
    }
    
    struct RepeatGroup: Identifiable, Codable, Equatable {
        let id: UUID
        var repeatCount: Int
        var steps: [StepSummary]
    }
    
    @State private var items: [StepItem] = [
        .step(.init(id: UUID(), name: "Alternating Cable Shoulder Press", mode: .exerciseTimed(seconds: 30))),
        .repeatGroup(.init(
            id: UUID(),
            repeatCount: 5,
            steps: [
                .init(id: UUID(), name: "Russian Twists", mode: .exerciseReps(count: 10)),
                .init(id: UUID(), name: "Push ups", mode: .exerciseReps(count: 10))
            ]
        )),
        .step(.init(id: UUID(), name: "Rest", mode: .restOpen)),
        .step(.init(id: UUID(), name: "Alternating Cable Shoulder Press", mode: .exerciseTimed(seconds: 30)))
    ]
    
    @State private var draggingItem: StepSummary? = nil
    @State private var draggingFromRepeat: UUID? = nil
    @State private var draggingRepeat: RepeatGroup? = nil
    @State private var hoveredRepeatId: UUID? = nil
    
    var body: some View {
    ScrollView {
        LazyVStack(spacing: 0) {
            // Top drop zone
            Rectangle()
                .fill(Color.pink)
                .frame(height: 30)
                .onDrop(
                    of: [.text],
                    delegate: InsertAtTopDelegate(
                        draggingItem: $draggingItem,
                        draggingFromRepeat: $draggingFromRepeat,
                        draggingRepeat: $draggingRepeat,
                        items: $items
                    )
                )

            ForEach(items) { item in
                VStack(spacing: 0) {
                    // Insert before drop zone
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 12)
                        .onDrop(
                            of: [.text],
                            delegate: InsertBeforeDropDelegate(
                                draggingItem: $draggingItem,
                                draggingFromRepeat: $draggingFromRepeat,
                                draggingRepeat: $draggingRepeat,
                                items: $items,
                                targetItem: item
                            )
                        )

                    switch item {
                    case .step(let step):
                        StepRowView(
                            stepName: step.name,
                            stepMode: step.mode,
                            onChangeType: { },
                            onChangeAmount: { },
                            onDelete: { removeItem(id: item.id) },
                            onRemoveFromRepeat: nil
                        )
                          .onDrag {
                              draggingItem = step
                              draggingFromRepeat = nil
                              draggingRepeat = nil
                              return NSItemProvider(object: step.id.uuidString as NSString)
                          }
                          .onDrop(
                              of: [.text],
                              delegate: ItemDropDelegate(
                                  draggingItem: $draggingItem,
                                  draggingFromRepeat: $draggingFromRepeat,
                                  draggingRepeat: $draggingRepeat,
                                  items: $items,
                                  hoveredRepeatId: $hoveredRepeatId,
                                  targetItem: item
                              )
                          )

                    case .repeatGroup(let group):
                        RepeatGroupView(
                            repeatCount: group.repeatCount,
                            steps: group.steps,
                            repeatId: group.id,
                            onStepDrag: { step in
                                draggingItem = step
                                draggingFromRepeat = group.id
                                draggingRepeat = nil
                                return NSItemProvider(object: step.id.uuidString as NSString)
                            },
                            onStepDrop: { targetStep in
                                RepeatStepDropDelegate(
                                    draggingItem: $draggingItem,
                                    draggingFromRepeat: $draggingFromRepeat,
                                    draggingRepeat: $draggingRepeat,
                                    items: $items,
                                    repeatGroupId: group.id,
                                    targetStep: targetStep
                                )
                            },
                            onStepDelete: { stepId in
                                removeStepFromRepeat(repeatId: group.id, stepId: stepId)
                            },
                            onGroupDelete: { removeItem(id: item.id) },
                            onGroupDrop: {
                                RepeatGroupDropDelegate(
                                    draggingItem: $draggingItem,
                                    draggingFromRepeat: $draggingFromRepeat,
                                    items: $items,
                                    hoveredRepeatId: $hoveredRepeatId,
                                    repeatGroupId: group.id
                                )
                            },
                            onRemoveFromRepeat: { stepId in
                                moveStepOutOfRepeat(repeatId: group.id, stepId: stepId)
                            },
                            isHighlighted: hoveredRepeatId == group.id
                        )
                        .onDrag {
                            draggingItem = nil
                            draggingFromRepeat = nil
                            draggingRepeat = group
                            return NSItemProvider(object: group.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: ItemDropDelegate(
                                draggingItem: $draggingItem,
                                draggingFromRepeat: $draggingFromRepeat,
                                draggingRepeat: $draggingRepeat,
                                items: $items,
                                hoveredRepeatId: $hoveredRepeatId,
                                targetItem: item
                            )
                        )
                    }

                    // Insert after drop zone
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 12)
                        .onDrop(
                            of: [.text],
                            delegate: InsertAfterDropDelegate(
                                draggingItem: $draggingItem,
                                draggingFromRepeat: $draggingFromRepeat,
                                draggingRepeat: $draggingRepeat,
                                items: $items,
                                targetItem: item
                            )
                        )
                }
            }

            // End-of-list drop zone
            Rectangle()
                .fill(Color.pink)
                .frame(height: 60)
                .onDrop(
                    of: [.text],
                    delegate: EndDropDelegate(
                        draggingItem: $draggingItem,
                        draggingFromRepeat: $draggingFromRepeat,
                        draggingRepeat: $draggingRepeat,
                        items: $items
                    )
                )
        }
        .padding(.horizontal, 16)
    }
    .background(Color(UIColor.systemGroupedBackground))
}
    
    private func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
    }

    private func removeStepFromRepeat(repeatId: UUID, stepId: UUID) {
        guard let index = items.firstIndex(where: { $0.id == repeatId }),
              case .repeatGroup(var group) = items[index] else { return }

        group.steps.removeAll { $0.id == stepId }

        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }

    private func moveStepOutOfRepeat(repeatId: UUID, stepId: UUID) {
        guard let repeatIndex = items.firstIndex(where: { $0.id == repeatId }),
              case .repeatGroup(var group) = items[repeatIndex],
              let stepIndex = group.steps.firstIndex(where: { $0.id == stepId }) else { return }

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
}

private struct ItemDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RoutineEditView.RepeatGroup?
    @Binding var items: [RoutineEditView.StepItem]
    @Binding var hoveredRepeatId: UUID?
    let targetItem: RoutineEditView.StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                        return true
                    }
                    return false
                }) else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }

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
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }) else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }

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
              case .repeatGroup(var group) = items[index] else { return }
        
        group.steps.removeAll { $0.id == stepId }
        
        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

private struct RepeatStepDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RoutineEditView.RepeatGroup?
    @Binding var items: [RoutineEditView.StepItem]
    let repeatGroupId: UUID
    let targetStep: RoutineEditView.StepSummary
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }
        
        // Don't process if we're dragging from the same repeat and at the same position
        if let sourceRepeatId = draggingFromRepeat, 
           sourceRepeatId == repeatGroupId,
           let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
           case .repeatGroup(let group) = items[groupIndex],
           let fromIdx = group.steps.firstIndex(where: { $0.id == draggingItem.id }),
           let toIdx = group.steps.firstIndex(where: { $0.id == targetStep.id }),
           fromIdx == toIdx {
            return
        }
        
        withAnimation {
            // Handle moving within same repeat
            if let sourceRepeatId = draggingFromRepeat, sourceRepeatId == repeatGroupId {
                guard let groupIndex = items.firstIndex(where: { $0.id == repeatGroupId }),
                      case .repeatGroup(var group) = items[groupIndex],
                      let fromIdx = group.steps.firstIndex(where: { $0.id == draggingItem.id }),
                      let toIdx = group.steps.firstIndex(where: { $0.id == targetStep.id }),
                      fromIdx != toIdx else { return }
                
                group.steps.move(fromOffsets: IndexSet(integer: fromIdx),
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
                  case .repeatGroup(var group) = items[groupIndex] else { return true }

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
              case .repeatGroup(var group) = items[index] else { return }
        
        group.steps.removeAll { $0.id == stepId }
        
        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

private struct RepeatGroupDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var items: [RoutineEditView.StepItem]
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
                  case .repeatGroup(var group) = items[groupIndex] else { return }

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
              case .repeatGroup(var group) = items[index] else { return }

        group.steps.removeAll { $0.id == stepId }

        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

private struct InsertAtTopDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RoutineEditView.RepeatGroup?
    @Binding var items: [RoutineEditView.StepItem]

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                        return true
                    }
                    return false
                }) else { return }

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
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }) else { return }

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
              case .repeatGroup(var group) = items[index] else { return }

        group.steps.removeAll { $0.id == stepId }

        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

private struct InsertBeforeDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RoutineEditView.RepeatGroup?
    @Binding var items: [RoutineEditView.StepItem]
    let targetItem: RoutineEditView.StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                        return true
                    }
                    return false
                }) else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }

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
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }) else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }

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
              case .repeatGroup(var group) = items[index] else { return }

        group.steps.removeAll { $0.id == stepId }

        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

private struct InsertAfterDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RoutineEditView.RepeatGroup?
    @Binding var items: [RoutineEditView.StepItem]
    let targetItem: RoutineEditView.StepItem

    func dropEntered(info: DropInfo) {
        withAnimation {
            // Handle dragging entire repeat group
            if let draggingRepeat = draggingRepeat {
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .repeatGroup(let r) = item, r.id == draggingRepeat.id {
                        return true
                    }
                    return false
                }) else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }

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
                guard let currentIndex = items.firstIndex(where: { item in
                    if case .step(let s) = item, s.id == draggingItem.id {
                        return true
                    }
                    return false
                }) else { return }

                guard let targetIndex = items.firstIndex(where: { $0.id == targetItem.id }) else { return }

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
              case .repeatGroup(var group) = items[index] else { return }

        group.steps.removeAll { $0.id == stepId }

        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

private struct EndDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var draggingFromRepeat: UUID?
    @Binding var draggingRepeat: RoutineEditView.RepeatGroup?
    @Binding var items: [RoutineEditView.StepItem]
    
    func performDrop(info: DropInfo) -> Bool {
        withAnimation {
            // Handle dragging entire repeat
            if let draggingRepeat = draggingRepeat {
                if case .repeatGroup(let lastRepeat) = items.last, lastRepeat.id == draggingRepeat.id {
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
              case .repeatGroup(var group) = items[index] else { return }
        
        group.steps.removeAll { $0.id == stepId }
        
        if group.steps.isEmpty {
            items.remove(at: index)
        } else {
            items[index] = .repeatGroup(group)
        }
    }
}

#Preview {
    RoutineEditView()
}
