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
    
    // Derive display name and detail from the summary string
    private func nameAndDetail(from summary: String) -> (name: String, detail: String) {
        // Exercise: <name> – <Open | N sec | N reps>
        if summary.hasPrefix("Exercise: ") {
            let afterPrefix = summary.dropFirst("Exercise: ".count)
            if let sep = afterPrefix.range(of: " – ") {
                let name = String(afterPrefix[..<sep.lowerBound])
                let suffix = String(afterPrefix[sep.upperBound...])
                if suffix == "Open" {
                    return (name, "Open")
                } else if suffix.hasSuffix(" sec") {
                    let valueStr = suffix.replacingOccurrences(of: " sec", with: "")
                    return (name, "\(valueStr) seconds")
                } else if suffix.hasSuffix(" reps") {
                    return (name, suffix) // e.g. "10 reps"
                }
                return (name, suffix)
            } else {
                return (String(afterPrefix), "")
            }
        }
        // Rest – <Open | N sec>
        if summary.hasPrefix("Rest – ") {
            let suffix = summary.dropFirst("Rest – ".count)
            if suffix == "Open" {
                return ("Rest", "Open")
            } else if suffix.hasSuffix(" sec") {
                let valueStr = suffix.replacingOccurrences(of: " sec", with: "")
                return ("Rest", "\(valueStr) seconds")
            }
            return ("Rest", String(suffix))
        }
        // Fallback
        return (summary, "tap to edit")
    }
    
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
                    ForEach(addedStepSummaries, id: \.id) { step in
                        let parts = nameAndDetail(from: step.summary)
                        StepRowView(
                            stepName: parts.name,
                            stepDetail: parts.detail,
                            onChangeType: {
                                editingStepID = step.id
                                selectedEditAction = .changeType
                                showingEditSheet = true
                            },
                            onChangeAmount: {
                                editingStepID = step.id
                                selectedEditAction = .changeAmount
                                showingEditSheet = true
                            },
                            onDelete: {
                                editingStepID = step.id
                                selectedEditAction = .delete
                                showingEditSheet = true
                            }
                        )
                    }
                    .onMove { indices, newOffset in
                        addedStepSummaries.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(UIColor.systemGroupedBackground))
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