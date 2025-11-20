import SwiftUI
import UniformTypeIdentifiers

struct RoutineEditView: View {
    @State private var viewModel = RoutineEditViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Top drop zone
                    DropZoneView(
                        height: 30,
                        color: .pink,
                        delegate: InsertAtTopDelegate(
                            draggingItem: $viewModel.draggingItem,
                            draggingFromRepeat: $viewModel.draggingFromRepeat,
                            draggingRepeat: $viewModel.draggingRepeat,
                            items: $viewModel.items
                        )
                    )

                    ForEach(viewModel.items) { item in
                        VStack(spacing: 0) {
                            // Insert before drop zone
                            DropZoneView(
                                delegate: InsertBeforeDropDelegate(
                                    draggingItem: $viewModel.draggingItem,
                                    draggingFromRepeat: $viewModel.draggingFromRepeat,
                                    draggingRepeat: $viewModel.draggingRepeat,
                                    items: $viewModel.items,
                                    targetItem: item
                                )
                            )

                            // Render the item
                            renderItem(item)

                            // Insert after drop zone
                            DropZoneView(
                                delegate: InsertAfterDropDelegate(
                                    draggingItem: $viewModel.draggingItem,
                                    draggingFromRepeat: $viewModel.draggingFromRepeat,
                                    draggingRepeat: $viewModel.draggingRepeat,
                                    items: $viewModel.items,
                                    targetItem: item
                                )
                            )
                        }
                    }

                    // End-of-list drop zone
                    DropZoneView(
                        height: 60,
                        color: .pink,
                        delegate: EndDropDelegate(
                            draggingItem: $viewModel.draggingItem,
                            draggingFromRepeat: $viewModel.draggingFromRepeat,
                            draggingRepeat: $viewModel.draggingRepeat,
                            items: $viewModel.items
                        )
                    )
                }
                .padding(.horizontal, 16)
            }
            .background(Color(UIColor.systemGroupedBackground))

            // Floating add button
            addButton
        }
        .sheet(isPresented: .constant(viewModel.isEditingStep)) {
            editStepSheet
        }
        .sheet(isPresented: .constant(viewModel.isEditingRepeatCount)) {
            editRepeatCountSheet
        }
        .sheet(isPresented: $viewModel.showNewStepSheet) {
            newStepSheet
        }
    }

    // MARK: - View Builders

    @ViewBuilder
    private func renderItem(_ item: StepItem) -> some View {
        switch item {
        case .step(let step):
            renderStepItem(step, item: item)
        case .repeatGroup(let group):
            renderRepeatGroupItem(group, item: item)
        }
    }

    private func renderStepItem(_ step: StepSummary, item: StepItem) -> some View {
        StepRowView(
            stepName: step.name,
            stepMode: step.mode,
            onChangeType: {
                viewModel.handleStepEdit(stepId: step.id, repeatId: nil, action: .changeType)
            },
            onChangeAmount: {
                viewModel.handleStepEdit(stepId: step.id, repeatId: nil, action: .changeAmount)
            },
            onDelete: { viewModel.removeItem(id: item.id) },
            onRemoveFromRepeat: nil
        )
        .onDrag {
            viewModel.draggingItem = step
            viewModel.draggingFromRepeat = nil
            viewModel.draggingRepeat = nil
            return NSItemProvider(object: step.id.uuidString as NSString)
        }
        .onDrop(
            of: [.text],
            delegate: ItemDropDelegate(
                draggingItem: $viewModel.draggingItem,
                draggingFromRepeat: $viewModel.draggingFromRepeat,
                draggingRepeat: $viewModel.draggingRepeat,
                items: $viewModel.items,
                hoveredRepeatId: $viewModel.hoveredRepeatId,
                targetItem: item
            )
        )
    }

    private func renderRepeatGroupItem(_ group: RepeatGroup, item: StepItem) -> some View {
        RepeatGroupView(
            repeatCount: group.repeatCount,
            steps: group.steps,
            repeatId: group.id,
            onStepDrag: { step in
                viewModel.draggingItem = step
                viewModel.draggingFromRepeat = group.id
                viewModel.draggingRepeat = nil
                return NSItemProvider(object: step.id.uuidString as NSString)
            },
            onStepDrop: { targetStep in
                RepeatStepDropDelegate(
                    draggingItem: $viewModel.draggingItem,
                    draggingFromRepeat: $viewModel.draggingFromRepeat,
                    draggingRepeat: $viewModel.draggingRepeat,
                    items: $viewModel.items,
                    repeatGroupId: group.id,
                    targetStep: targetStep
                )
            },
            onStepDelete: { stepId in
                viewModel.removeStepFromRepeat(repeatId: group.id, stepId: stepId)
            },
            onStepChangeType: { stepId in
                viewModel.handleStepEdit(stepId: stepId, repeatId: group.id, action: .changeType)
            },
            onStepChangeAmount: { stepId in
                viewModel.handleStepEdit(stepId: stepId, repeatId: group.id, action: .changeAmount)
            },
            onGroupChangeCount: {
                viewModel.handleRepeatCountEdit(repeatId: group.id)
            },
            onGroupDelete: { viewModel.removeItem(id: item.id) },
            onGroupDrop: {
                RepeatGroupDropDelegate(
                    draggingItem: $viewModel.draggingItem,
                    draggingFromRepeat: $viewModel.draggingFromRepeat,
                    items: $viewModel.items,
                    hoveredRepeatId: $viewModel.hoveredRepeatId,
                    repeatGroupId: group.id
                )
            },
            onRemoveFromRepeat: { stepId in
                viewModel.moveStepOutOfRepeat(repeatId: group.id, stepId: stepId)
            },
            isHighlighted: viewModel.hoveredRepeatId == group.id
        )
        .onDrag {
            viewModel.draggingItem = nil
            viewModel.draggingFromRepeat = nil
            viewModel.draggingRepeat = group
            return NSItemProvider(object: group.id.uuidString as NSString)
        }
        .onDrop(
            of: [.text],
            delegate: ItemDropDelegate(
                draggingItem: $viewModel.draggingItem,
                draggingFromRepeat: $viewModel.draggingFromRepeat,
                draggingRepeat: $viewModel.draggingRepeat,
                items: $viewModel.items,
                hoveredRepeatId: $viewModel.hoveredRepeatId,
                targetItem: item
            )
        )
    }

    private var addButton: some View {
        VStack {
            Spacer()
            Button(action: { viewModel.showNewStepSheet = true }) {
                Label("Add Step", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
    }

    // MARK: - Sheet Views

    @ViewBuilder
    private var editStepSheet: some View {
        if let stepId = viewModel.editingStepId,
            let action = viewModel.editAction
        {
            if let repeatId = viewModel.editingRepeatId {
                editStepInRepeatSheet(stepId: stepId, repeatId: repeatId, action: action)
            } else {
                editTopLevelStepSheet(stepId: stepId, action: action)
            }
        }
    }

    @ViewBuilder
    private func editStepInRepeatSheet(stepId: UUID, repeatId: UUID, action: StepEditAction)
        -> some View
    {
        if let repeatIndex = viewModel.items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let group) = viewModel.items[repeatIndex],
            let stepIndex = group.steps.firstIndex(where: { $0.id == stepId })
        {
            let step = group.steps[stepIndex]
            EditStepSheet(
                sheetDetent: $viewModel.sheetDetent,
                stepName: step.name,
                stepMode: step.mode,
                action: action,
                onUpdateSummary: { newMode in
                    viewModel.updateStepInRepeat(
                        repeatId: repeatId, stepId: stepId, newMode: newMode)
                    viewModel.closeEditSheet()
                },
                onDelete: {
                    viewModel.removeStepFromRepeat(repeatId: repeatId, stepId: stepId)
                    viewModel.closeEditSheet()
                }
            )
        }
    }

    @ViewBuilder
    private func editTopLevelStepSheet(stepId: UUID, action: StepEditAction) -> some View {
        if let itemIndex = viewModel.items.firstIndex(where: { $0.id == stepId }),
            case .step(let step) = viewModel.items[itemIndex]
        {
            EditStepSheet(
                sheetDetent: $viewModel.sheetDetent,
                stepName: step.name,
                stepMode: step.mode,
                action: action,
                onUpdateSummary: { newMode in
                    viewModel.updateTopLevelStep(stepId: stepId, newMode: newMode)
                    viewModel.closeEditSheet()
                },
                onDelete: {
                    viewModel.removeItem(id: stepId)
                    viewModel.closeEditSheet()
                }
            )
        }
    }

    @ViewBuilder
    private var editRepeatCountSheet: some View {
        if let repeatId = viewModel.editingRepeatCountId,
            let repeatIndex = viewModel.items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(let group) = viewModel.items[repeatIndex]
        {
            RepeatCountEditSheet(
                sheetDetent: $viewModel.repeatCountSheetDetent,
                currentCount: group.repeatCount,
                onSave: { newCount in
                    viewModel.updateRepeatCount(repeatId: repeatId, newCount: newCount)
                    viewModel.closeRepeatCountSheet()
                },
                onCancel: {
                    viewModel.closeRepeatCountSheet()
                }
            )
        }
    }

    private var newStepSheet: some View {
        NewStepSheet(
            sheetDetent: $viewModel.newStepSheetDetent,
            onAddStep: { name, mode in
                viewModel.handleAddStep(name: name, mode: mode)
            },
            onStartRepeatFlow: {
                viewModel.handleStartRepeatFlow()
            }
        )
    }
}

#Preview {
    RoutineEditView()
}
