import SwiftUI

struct RoutineEditView: View {
    // Add a stable, identifiable row model
    private struct StepItem: Identifiable, Equatable {
        let id: UUID
        var summary: String
        init(id: UUID = UUID(), summary: String) {
            self.id = id
            self.summary = summary
        }
    }

    // Replace [String] with identifiable items
    @State private var addedStepSummaries: [StepItem] = []
    @State private var showingNewStepSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var sheetDetent: PresentationDetent = .medium
    @State private var showingEditSheet: Bool = false
    // Track the item by ID instead of index to avoid index becoming stale during moves
    @State private var editingStepID: UUID?
    @State private var selectedEditAction: StepEditAction?
    @State private var editMode: EditMode = .active
    
    var body: some View {
        VStack {
            Button(action: {
                showingNewStepSheet = true
            }) {
                Text("Add a step")
            }
            .buttonStyle(.bordered)
            
            // Show the steps added from the sheet flow
            if addedStepSummaries.isEmpty {
                Text("No steps yet")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                List {
                    // KEY FIX: Remove Section wrapper - just use ForEach directly
                    ForEach(addedStepSummaries, id: \.id) { step in
                        HStack {
                            Text(step.summary)
                            Spacer()
                            Menu {
                                Button("Change Type") {
                                    editingStepID = step.id
                                    selectedEditAction = .changeType
                                    showingEditSheet = true
                                }
                                Button("Change Duration/Reps") {
                                    editingStepID = step.id
                                    selectedEditAction = .changeAmount
                                    showingEditSheet = true
                                }
                                Button(role: .destructive) {
                                    editingStepID = step.id
                                    selectedEditAction = .delete
                                    showingEditSheet = true
                                } label: {
                                    Text("Delete")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.medium)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onMove { indices, newOffset in
                        addedStepSummaries.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .listStyle(.insetGrouped)
                // Bind edit mode (avoid constant .active which can cause diff thrashing)
                .environment(\.editMode, $editMode)
            }
        }
        .sheet(isPresented: $showingNewStepSheet) {
            NewStepSheet(
                sheetDetent: $sheetDetent,
                onAddSummary: { summary in
                    addedStepSummaries.append(.init(summary: summary))
                }
            )
            .presentationDetents([.medium, .large], selection: $sheetDetent)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let id = editingStepID, let action = selectedEditAction,
               let idx = addedStepSummaries.firstIndex(where: { $0.id == id }) {
                EditStepSheet(
                    sheetDetent: $sheetDetent,
                    initialSummary: addedStepSummaries[idx].summary,
                    action: action,
                    onUpdateSummary: { updated in
                        addedStepSummaries[idx].summary = updated
                    },
                    onDelete: {
                        addedStepSummaries.remove(at: idx)
                    }
                )
                .presentationDetents([.medium, .large], selection: $sheetDetent)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                // Optional: let users toggle edit mode; start active but avoid constant binding
                EditButton()
            }
        }
    }
}

#Preview {
    RoutineEditView()
}