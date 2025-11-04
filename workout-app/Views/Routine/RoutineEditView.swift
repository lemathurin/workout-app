import SwiftUI

struct RoutineEditView: View {
    @State private var showingNewStepSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var sheetDetent: PresentationDetent = .medium
    @State private var addedStepSummaries: [String] = []
    @State private var showingEditSheet: Bool = false
    @State private var editingStepIndex: Int?
    @State private var selectedEditAction: StepEditAction?
    
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
                    // Use index-based identity to support duplicates
                    ForEach(Array(addedStepSummaries.enumerated()), id: \.offset) { index, summary in
                        HStack {
                            Text(summary)
                            Spacer()
                            Menu {
                                Button("Change Type") {
                                    editingStepIndex = index
                                    selectedEditAction = .changeType
                                    showingEditSheet = true
                                }
                                Button("Change Duration/Reps") {
                                    editingStepIndex = index
                                    selectedEditAction = .changeAmount
                                    showingEditSheet = true
                                }
                                Button(role: .destructive) {
                                    editingStepIndex = index
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
                    }
                    .onMove { indices, newOffset in
                        addedStepSummaries.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .listStyle(.insetGrouped)
                // Force edit mode active so grabbers are visible
                .environment(\.editMode, .constant(.active))
            }
        }
        .sheet(isPresented: $showingNewStepSheet) {
            NewStepSheet(
                sheetDetent: $sheetDetent,
                onAddSummary: { summary in
                    addedStepSummaries.append(summary)
                }
            )
            .presentationDetents([.medium, .large], selection: $sheetDetent)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let idx = editingStepIndex, let action = selectedEditAction {
                EditStepSheet(
                    sheetDetent: $sheetDetent,
                    initialSummary: addedStepSummaries[idx],
                    action: action,
                    onUpdateSummary: { updated in
                        addedStepSummaries[idx] = updated
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
                Button("Save") { }
            }
        }
    }
}

#Preview {
    RoutineEditView()
}
