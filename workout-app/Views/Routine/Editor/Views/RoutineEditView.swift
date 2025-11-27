import SwiftUI
import SwiftData

import UniformTypeIdentifiers

struct RoutineEditView: View {
    let routine: Routine?
    @Query private var exercises: [Exercise]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = RoutineEditViewModel()
    
    init(routine: Routine? = nil) {
        self.routine = routine
    }

    @State private var showDiscardAlert = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        Text("Routine Name")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)

                        TextField("Routine Name", text: $viewModel.routineName, axis: .vertical)
                            .lineLimit(1...5)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.vertical, 15)
                            .padding(.horizontal, 17)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .cornerRadius(20)
                            .padding(.bottom, 12)
                            .submitLabel(.done)
                            .onSubmit {
                                // Dismiss keyboard
                                UIApplication.shared.sendAction(
                                    #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                                    for: nil)
                            }

                        Text("Steps")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)
                            .padding(.bottom, 6)

                        if viewModel.items.isEmpty {
                            ContentUnavailableView(
                                "No Steps Yet",
                                systemImage: "figure.walk",
                                description: Text(
                                    "Tap the button below to start building your routine")
                            )
                            .padding(.vertical, 40)
                        }

                        ForEach(viewModel.items) { item in
                            VStack(spacing: 0) {
                                // Insert before drop zone
                                DropZoneView(
                                    height: 6,
                                    color: .clear,
                                    delegate: InsertDropDelegate(
                                        position: .before(item),
                                        draggingItem: $viewModel.draggingItem,
                                        draggingFromRepeat: $viewModel.draggingFromRepeat,
                                        draggingRepeatId: $viewModel.draggingRepeatId,
                                        items: $viewModel.items
                                    )
                                )

                                // Render the item
                                renderItem(item)

                                // Insert after drop zone
                                DropZoneView(
                                    height: 6,
                                    color: .clear,
                                    delegate: InsertDropDelegate(
                                        position: .after(item),
                                        draggingItem: $viewModel.draggingItem,
                                        draggingFromRepeat: $viewModel.draggingFromRepeat,
                                        draggingRepeatId: $viewModel.draggingRepeatId,
                                        items: $viewModel.items
                                    )
                                )
                            }
                        }

                        // End-of-list drop zone
                        DropZoneView(
                            height: 100,
                            color: .clear,
                            delegate: InsertDropDelegate(
                                position: .end,
                                draggingItem: $viewModel.draggingItem,
                                draggingFromRepeat: $viewModel.draggingFromRepeat,
                                draggingRepeatId: $viewModel.draggingRepeatId,
                                items: $viewModel.items
                            )
                        )
                    }
                    .padding(.horizontal, 16)
                }
                .background(Color(UIColor.systemGroupedBackground))
                .simultaneousGesture(
                    TapGesture().onEnded {
                        // Dismiss keyboard when tapping anywhere
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                            for: nil)
                    }
                )

                Button(
                    action: {
                        viewModel.showChooseStepKindSheet = true
                    },
                    label: {
                        Label("Add a step", systemImage: "plus")
                    }
                )
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 10)

            }
            .sheet(isPresented: .constant(viewModel.isEditingStep)) {
                editStepSheet
                    .presentationDetents([.height(300)])
                    .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: .constant(viewModel.isEditingRepeatCount)) {
                editRepeatCountSheet
                    .presentationDetents([.height(300)])
                    .interactiveDismissDisabled(true)
            }
            .sheet(isPresented: $viewModel.showChooseStepKindSheet) {
                ChooseStepKindSheet(
                    onAddExercise: { exerciseId, name, mode in
                        if let exerciseMode = stepModeToExerciseMode(mode) {
                            viewModel.handleAddExercise(
                                exerciseId: exerciseId, name: name, mode: exerciseMode)
                        }
                    },
                    onAddRest: { mode in
                        if let restMode = stepModeToRestMode(mode) {
                            viewModel.handleAddRest(mode: restMode)
                        }
                    },
                    onStartRepeatFlow: { count in
                        viewModel.handleStartRepeatFlow(count: count)
                    }
                )
                .presentationDetents([.height(300)])
                .interactiveDismissDisabled(true)
            }
            .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        showDiscardAlert = true
                    }) {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    let isValid =
                        !viewModel.routineName.trimmingCharacters(in: .whitespaces).isEmpty
                        && !viewModel.items.isEmpty

                    Button(action: {
                        if let routine = viewModel.editingRoutine {
                            // Update existing routine
                            if let updatedRoutine = viewModel.buildRoutine() {
                                routine.translations = updatedRoutine.translations
                                routine.steps = updatedRoutine.steps
                                routine.metadata.updateTimestamp()
                            }
                        } else {
                            // Create new routine
                            if let routine = viewModel.buildRoutine() {
                                modelContext.insert(routine)
                            }
                        }
                        dismiss()
                    }) {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                    .opacity(isValid ? 1.0 : 0.5)
                    .disabled(!isValid)
                }
            }

            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    dismiss()
                }
            } message: {
                Text("Your changes won't be saved.")
            }
        }
        .task {
            if let routine = routine {
                viewModel.loadRoutine(routine, exercises: exercises)
            }
        }

    }

    // MARK: - View Builders

    @ViewBuilder
    private func renderItem(_ item: StepItem) -> some View {
        switch item {
        case .exercise(let id, let exerciseId, let name, let mode):
            renderExercise(id: id, exerciseId: exerciseId, name: name, mode: mode, item: item)
        case .rest(let id, let mode):
            renderRest(id: id, mode: mode, item: item)
        case .repeatGroup(let id, let count, let items):
            renderRepeatGroup(id: id, count: count, items: items, item: item)
        }
    }

    private func renderExercise(
        id: UUID, exerciseId: String, name: String, mode: ExerciseStepMode, item: StepItem
    )
        -> some View
    {
        StepRowView(
            stepName: name,
            stepMode: exerciseModeToStepMode(mode),
            onChangeType: {
                viewModel.handleStepEdit(itemId: id, repeatId: nil, action: .changeType)
            },
            onChangeAmount: {
                viewModel.handleStepEdit(itemId: id, repeatId: nil, action: .changeAmount)
            },
            onDuplicate: { viewModel.duplicateStep(id: id) },
            onDelete: { viewModel.removeItem(id: id) },
            onRemoveFromRepeat: nil
        )
        .onDrag {
            viewModel.draggingItem = .exercise(
                id: id, exerciseId: exerciseId, name: name, mode: mode)
            viewModel.draggingFromRepeat = nil
            viewModel.draggingRepeatId = nil
            return NSItemProvider(object: id.uuidString as NSString)
        }
        .onDrop(
            of: [.text],
            delegate: ItemDropDelegate(
                draggingItem: $viewModel.draggingItem,
                draggingFromRepeat: $viewModel.draggingFromRepeat,
                draggingRepeatId: $viewModel.draggingRepeatId,
                items: $viewModel.items,
                hoveredRepeatId: $viewModel.hoveredRepeatId,
                targetItem: item
            )
        )
    }

    private func renderRest(id: UUID, mode: RestStepMode, item: StepItem) -> some View {
        StepRowView(
            stepName: "Rest",
            stepMode: restModeToStepMode(mode),
            onChangeType: {
                viewModel.handleStepEdit(itemId: id, repeatId: nil, action: .changeType)
            },
            onChangeAmount: {
                viewModel.handleStepEdit(itemId: id, repeatId: nil, action: .changeAmount)
            },
            onDuplicate: { viewModel.duplicateStep(id: id) },
            onDelete: { viewModel.removeItem(id: id) },
            onRemoveFromRepeat: nil
        )
        .onDrag {
            viewModel.draggingItem = .rest(id: id, mode: mode)
            viewModel.draggingFromRepeat = nil
            viewModel.draggingRepeatId = nil
            return NSItemProvider(object: id.uuidString as NSString)
        }
        .onDrop(
            of: [.text],
            delegate: ItemDropDelegate(
                draggingItem: $viewModel.draggingItem,
                draggingFromRepeat: $viewModel.draggingFromRepeat,
                draggingRepeatId: $viewModel.draggingRepeatId,
                items: $viewModel.items,
                hoveredRepeatId: $viewModel.hoveredRepeatId,
                targetItem: item
            )
        )
    }

    private func renderRepeatGroup(id: UUID, count: Int, items: [RepeatItem], item: StepItem)
        -> some View
    {
        RepeatGroupView(
            repeatCount: count,
            items: items,
            repeatId: id,
            onItemDrag: { repeatItem in
                viewModel.draggingItem = repeatItem
                viewModel.draggingFromRepeat = id
                viewModel.draggingRepeatId = nil
                return NSItemProvider(object: repeatItem.id.uuidString as NSString)
            },
            onItemDrop: { targetItem in
                RepeatStepDropDelegate(
                    draggingItem: $viewModel.draggingItem,
                    draggingFromRepeat: $viewModel.draggingFromRepeat,
                    draggingRepeatId: $viewModel.draggingRepeatId,
                    items: $viewModel.items,
                    repeatGroupId: id,
                    targetItem: targetItem
                )
            },
            onItemDelete: { itemId in
                viewModel.removeItemFromRepeat(repeatId: id, itemId: itemId)
            },
            onItemChangeType: { itemId in
                viewModel.handleStepEdit(itemId: itemId, repeatId: id, action: .changeType)
            },
            onItemChangeAmount: { itemId in
                viewModel.handleStepEdit(itemId: itemId, repeatId: id, action: .changeAmount)
            },
            onItemDuplicate: { itemId in
                viewModel.duplicateStepInRepeat(repeatId: id, itemId: itemId)
            },
            onGroupChangeCount: {
                viewModel.handleRepeatCountEdit(repeatId: id)
            },
            onGroupDuplicate: {
                viewModel.duplicateRepeatGroup(id: id)
            },
            onGroupDelete: { viewModel.removeItem(id: id) },
            onGroupDrop: {
                RepeatGroupDropDelegate(
                    draggingItem: $viewModel.draggingItem,
                    draggingFromRepeat: $viewModel.draggingFromRepeat,
                    items: $viewModel.items,
                    hoveredRepeatId: $viewModel.hoveredRepeatId,
                    repeatGroupId: id
                )
            },
            onRemoveFromRepeat: { itemId in
                viewModel.moveItemOutOfRepeat(repeatId: id, itemId: itemId)
            },
            isHighlighted: viewModel.hoveredRepeatId == id
        )
        .onDrag {
            viewModel.draggingItem = nil
            viewModel.draggingFromRepeat = nil
            viewModel.draggingRepeatId = id
            return NSItemProvider(object: id.uuidString as NSString)
        }
        .onDrop(
            of: [.text],
            delegate: ItemDropDelegate(
                draggingItem: $viewModel.draggingItem,
                draggingFromRepeat: $viewModel.draggingFromRepeat,
                draggingRepeatId: $viewModel.draggingRepeatId,
                items: $viewModel.items,
                hoveredRepeatId: $viewModel.hoveredRepeatId,
                targetItem: item
            )
        )
    }

    // MARK: - Sheet Views

    @ViewBuilder
    private var editStepSheet: some View {
        if let itemId = viewModel.editingItemId,
            let action = viewModel.editAction
        {
            if let repeatId = viewModel.editingRepeatId {
                editStepInRepeatSheet(itemId: itemId, repeatId: repeatId, action: action)
            } else {
                editTopLevelStepSheet(itemId: itemId, action: action)
            }
        }
    }

    @ViewBuilder
    private func editStepInRepeatSheet(itemId: UUID, repeatId: UUID, action: StepEditAction)
        -> some View
    {
        if let repeatIndex = viewModel.items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(_, _, let repeatItems) = viewModel.items[repeatIndex],
            let itemIndex = repeatItems.firstIndex(where: { $0.id == itemId })
        {

            let repeatItem = repeatItems[itemIndex]

            switch repeatItem {
            case .exercise(_, _, let name, let mode):
                EditStepSheet(
                    sheetDetent: $viewModel.sheetDetent,
                    stepName: name,
                    stepMode: exerciseModeToStepMode(mode),
                    action: action,
                    onUpdateSummary: { newStepMode in
                        if let newMode = stepModeToExerciseMode(newStepMode) {
                            viewModel.updateExerciseInRepeat(
                                repeatId: repeatId, exerciseId: itemId, newMode: newMode)
                        }
                        viewModel.closeEditSheet()
                    },
                    onDelete: {
                        viewModel.removeItemFromRepeat(repeatId: repeatId, itemId: itemId)
                        viewModel.closeEditSheet()
                    },
                    onCancel: {
                        viewModel.closeEditSheet()
                    }
                )
            case .rest(_, let mode):
                EditStepSheet(
                    sheetDetent: $viewModel.sheetDetent,
                    stepName: "Rest",
                    stepMode: restModeToStepMode(mode),
                    action: action,
                    onUpdateSummary: { newStepMode in
                        if let newMode = stepModeToRestMode(newStepMode) {
                            viewModel.updateRestInRepeat(
                                repeatId: repeatId, restId: itemId, newMode: newMode)
                        }
                        viewModel.closeEditSheet()
                    },
                    onDelete: {
                        viewModel.removeItemFromRepeat(repeatId: repeatId, itemId: itemId)
                        viewModel.closeEditSheet()
                    },
                    onCancel: {
                        viewModel.closeEditSheet()
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func editTopLevelStepSheet(itemId: UUID, action: StepEditAction) -> some View {
        if let itemIndex = viewModel.items.firstIndex(where: { $0.id == itemId }) {
            let item = viewModel.items[itemIndex]

            switch item {
            case .exercise(_, _, let name, let mode):
                EditStepSheet(
                    sheetDetent: $viewModel.sheetDetent,
                    stepName: name,
                    stepMode: exerciseModeToStepMode(mode),
                    action: action,
                    onUpdateSummary: { newStepMode in
                        if let newMode = stepModeToExerciseMode(newStepMode) {
                            viewModel.updateExerciseMode(id: itemId, newMode: newMode)
                        }
                        viewModel.closeEditSheet()
                    },
                    onDelete: {
                        viewModel.removeItem(id: itemId)
                        viewModel.closeEditSheet()
                    },
                    onCancel: {
                        viewModel.closeEditSheet()
                    }
                )
            case .rest(_, let mode):
                EditStepSheet(
                    sheetDetent: $viewModel.sheetDetent,
                    stepName: "Rest",
                    stepMode: restModeToStepMode(mode),
                    action: action,
                    onUpdateSummary: { newStepMode in
                        if let newMode = stepModeToRestMode(newStepMode) {
                            viewModel.updateRestMode(id: itemId, newMode: newMode)
                        }
                        viewModel.closeEditSheet()
                    },
                    onDelete: {
                        viewModel.removeItem(id: itemId)
                        viewModel.closeEditSheet()
                    },
                    onCancel: {
                        viewModel.closeEditSheet()
                    }
                )
            case .repeatGroup:
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var editRepeatCountSheet: some View {
        if let repeatId = viewModel.editingRepeatCountId,
            let repeatIndex = viewModel.items.firstIndex(where: { $0.id == repeatId }),
            case .repeatGroup(_, let count, _) = viewModel.items[repeatIndex]
        {
            RepeatCountEditSheet(
                sheetDetent: $viewModel.repeatCountSheetDetent,
                currentCount: count,
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

    // MARK: - Helper Methods (Conversion between StepMode and specific modes)

    private func exerciseModeToStepMode(_ mode: ExerciseStepMode) -> StepMode {
        switch mode {
        case .timed(let seconds):
            return .exerciseTimed(seconds: seconds)
        case .reps(let count):
            return .exerciseReps(count: count)
        case .open:
            return .exerciseOpen
        }
    }

    private func restModeToStepMode(_ mode: RestStepMode) -> StepMode {
        switch mode {
        case .timed(let seconds):
            return .restTimed(seconds: seconds)
        case .open:
            return .restOpen
        }
    }

    private func stepModeToExerciseMode(_ stepMode: StepMode) -> ExerciseStepMode? {
        switch stepMode {
        case .exerciseTimed(let seconds):
            return .timed(seconds: seconds)
        case .exerciseReps(let count):
            return .reps(count: count)
        case .exerciseOpen:
            return .open
        default:
            return nil
        }
    }

    private func stepModeToRestMode(_ stepMode: StepMode) -> RestStepMode? {
        switch stepMode {
        case .restTimed(let seconds):
            return .timed(seconds: seconds)
        case .restOpen:
            return .open
        default:
            return nil
        }
    }
}

#Preview {
    RoutineEditView()
}
