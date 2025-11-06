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

    // New: models to support repeat groups alongside steps
    private struct RepeatGroupItem: Identifiable, Equatable {
        let id: UUID
        var times: Int
        var stepIDs: [UUID]
    }

    private enum RoutineItem: Identifiable, Equatable {
        case step(StepItem)
        case repeatGroup(RepeatGroupItem)

        var id: UUID {
            switch self {
            case .step(let s): return s.id
            case .repeatGroup(let r): return r.id
            }
        }
    }

    // Replace [String] with identifiable items
    @State private var addedStepSummaries: [StepItem] = []
    @State private var routineItems: [RoutineItem] = []               // New: the displayed list
    @State private var showingNewStepSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var sheetDetent: PresentationDetent = .medium
    @State private var showingEditSheet: Bool = false
    // Track the item by ID instead of index to avoid index becoming stale during moves
    @State private var editingStepID: UUID?
    @State private var selectedEditAction: StepEditAction?
    @State private var editMode: EditMode = .active
    @State private var showingRepeatSheet: Bool = false               // New: full-screen repeat picker

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
            // Add buttons: steps and repeat
            HStack(spacing: 12) {
                Button(action: {
                    showingNewStepSheet = true
                }) {
                    Text("Add a step")
                }
                .buttonStyle(.bordered)

                Button(action: {
                    showingRepeatSheet = true
                }) {
                    Text("Add a repeat")
                }
                .buttonStyle(.borderedProminent)
            }

            // Show the items (steps + repeats)
            if routineItems.isEmpty {
                Text("No items yet")
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            } else {
                List {
                    ForEach(routineItems, id: \.id) { item in
                        Group {
                            if case .step(let step) = item {
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
                                        if let idx = routineItems.firstIndex(where: { $0.id == step.id }) {
                                            routineItems.remove(at: idx)
                                        }
                                    }
                                )
                            }
                            // Render multi-step repeat groups
                            else if case .repeatGroup(let rg) = item {
                                let repeatSteps: [RepeatGroupView.RepeatStep] = rg.stepIDs.compactMap { sid in
                                    guard let s = addedStepSummaries.first(where: { $0.id == sid }) else { return nil }
                                    let parts = nameAndDetail(from: s.summary)
                                    return .init(
                                        name: parts.name,
                                        detail: parts.detail,
                                        onChangeType: {
                                            editingStepID = s.id
                                            selectedEditAction = .changeType
                                            showingEditSheet = true
                                        },
                                        onChangeAmount: {
                                            editingStepID = s.id
                                            selectedEditAction = .changeAmount
                                            showingEditSheet = true
                                        },
                                        onDelete: {
                                            if let idx = routineItems.firstIndex(where: { $0.id == rg.id }) {
                                                var updated = rg
                                                updated.stepIDs.removeAll { $0 == sid }
                                                if updated.stepIDs.isEmpty {
                                                    routineItems.remove(at: idx)
                                                } else {
                                                    routineItems[idx] = .repeatGroup(updated)
                                                }
                                            }
                                        }
                                    )
                                }

                                RepeatGroupView(
                                    times: rg.times,
                                    steps: repeatSteps,
                                    onDeleteGroup: {
                                        if let idx = routineItems.firstIndex(where: { $0.id == rg.id }) {
                                            routineItems.remove(at: idx)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .onMove { indices, newOffset in
                        routineItems.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(UIColor.systemGroupedBackground))
                .environment(\.editMode, $editMode)
            }
        }
        // New Step creation sheet (unchanged, but also adds to displayed list)
        .sheet(isPresented: $showingNewStepSheet) {
            NewStepSheet(
                sheetDetent: $sheetDetent,
                onAddSummary: { summary in
                    let new = StepItem(summary: summary)
                    addedStepSummaries.append(new)
                    routineItems.append(.step(new))
                },
                // Hook: when “Repeat” is picked in Add Step sheet, open full-screen picker
                onStartRepeatFlow: {
                    showingRepeatSheet = true
                }
            )
            .presentationDetents([.medium, .large], selection: $sheetDetent)
        }
        // Full-screen repeat selection: multi-select + wheel picker
        .fullScreenCover(isPresented: $showingRepeatSheet) {
            RepeatSelectionSheet(
                steps: addedStepSummaries,
                nameResolver: { summary in
                    nameAndDetail(from: summary).name
                },
                onAddRepeat: { selectedIDs, times in
                    // Move selected steps into the repeat (don’t duplicate)
                    let indicesToRemove: [Int] = routineItems.enumerated().compactMap { idx, item in
                        if case .step(let s) = item, selectedIDs.contains(s.id) { return idx }
                        return nil
                    }
                    let insertIndex = indicesToRemove.min() ?? routineItems.count
                    for i in indicesToRemove.sorted(by: >) {
                        routineItems.remove(at: i)
                    }
                    routineItems.insert(.repeatGroup(.init(id: UUID(), times: times, stepIDs: selectedIDs)), at: insertIndex)
                }
            )
        }
        // Edit sheet for changing type/amount of the underlying step
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
                        let removedID = addedStepSummaries[idx].id
                        addedStepSummaries.remove(at: idx)
                        routineItems.removeAll {
                            if case .repeatGroup(let rg) = $0 { return rg.stepIDs.contains(removedID) }
                            if case .step(let s) = $0 { return s.id == removedID }
                            return false
                        }
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

    // Full-screen sheet to pick a step and times
    private struct RepeatSelectionSheet: View {
        let steps: [StepItem]
        let nameResolver: (String) -> String
        let onAddRepeat: ([UUID], Int) -> Void

        @Environment(\.dismiss) private var dismiss
        @State private var selectedStepIDs: Set<UUID> = []
        @State private var times: Int = 2

        var body: some View {
            NavigationStack {
                VStack {
                    List {
                        ForEach(steps, id: \.id) { s in
                            HStack(spacing: 12) {
                                Image(systemName: selectedStepIDs.contains(s.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedStepIDs.contains(s.id) ? .accentColor : .secondary)
                                Text(nameResolver(s.summary))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if selectedStepIDs.contains(s.id) {
                                    selectedStepIDs.remove(s.id)
                                } else {
                                    selectedStepIDs.insert(s.id)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)

                    if !selectedStepIDs.isEmpty {
                        HStack {
                            Text("Repeat")
                            Stepper("\(times) times", value: $times, in: 2...20)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }

                    Spacer()
                }
                .navigationTitle("Add Repeat")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Add") {
                            if !selectedStepIDs.isEmpty {
                                onAddRepeat(Array(selectedStepIDs), times)
                                dismiss()
                            }
                        }
                        .disabled(selectedStepIDs.isEmpty)
                    }
                }
            }
        }
    }
}

#Preview {
    RoutineEditView()
}