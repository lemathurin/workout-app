import SwiftUI
import UniformTypeIdentifiers

struct RoutineEditView: View {
    struct StepSummary: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var detail: String
    }

    @State private var steps: [StepSummary] = [
        .init(id: UUID(), name: "Alternating Cable Shoulder Press", detail: "30 sec"),
        .init(id: UUID(), name: "Plank", detail: "10 reps"),
        .init(id: UUID(), name: "Rest", detail: "Open"),
        .init(id: UUID(), name: "Russian Twists", detail: "30 sec"),
        .init(id: UUID(), name: "Barbell Bench Press", detail: "45 sec")
    ]

    @State private var draggingItem: StepSummary? = nil

    var body: some View {
    ScrollView {
        LazyVStack(spacing: 0) {
            ForEach(steps) { s in
                StepRowView(
                    stepName: s.name,
                    stepDetail: s.detail,
                    onChangeType: { /* hook to your editor */ },
                    onChangeAmount: { /* hook to your editor */ },
                    onDelete: { removeStep(id: s.id) }
                )
                .contentShape(Rectangle())
                .onDrag {
                    draggingItem = s
                    return NSItemProvider(object: s.id.uuidString as NSString)
                }
                .onDrop(
                    of: [.text],
                    delegate: StepReorderDropDelegate(
                        draggingItem: $draggingItem,
                        steps: $steps,
                        targetStep: s
                    )
                )
            }

            // End-of-list drop zone
            Rectangle()
                .fill(Color.clear)
                .frame(height: 16)
                .onDrop(
                    of: [.text],
                    delegate: EndDropDelegate(
                        draggingItem: $draggingItem,
                        steps: $steps
                    )
                )
        }
    }
}

    private func removeStep(id: UUID) {
        steps.removeAll { $0.id == id }
    }
}

// MARK: - Drop Delegates

private struct StepReorderDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var steps: [RoutineEditView.StepSummary]
    let targetStep: RoutineEditView.StepSummary

    func dropEntered(info: DropInfo) {
        guard let draggingItem = draggingItem else { return }
        
        if draggingItem != targetStep {
            let fromIndex = steps.firstIndex(of: draggingItem)
            let toIndex = steps.firstIndex(of: targetStep)
            
            if let fromIndex = fromIndex, let toIndex = toIndex, fromIndex != toIndex {
                withAnimation {
                    steps.move(
                        fromOffsets: IndexSet(integer: fromIndex),
                        toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
                    )
                }
            }
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }
}

private struct EndDropDelegate: DropDelegate {
    @Binding var draggingItem: RoutineEditView.StepSummary?
    @Binding var steps: [RoutineEditView.StepSummary]

    func performDrop(info: DropInfo) -> Bool {
        guard let draggingItem = draggingItem,
              let fromIndex = steps.firstIndex(of: draggingItem) else {
            return false
        }

        withAnimation {
            steps.move(
                fromOffsets: IndexSet(integer: fromIndex),
                toOffset: steps.count
            )
        }
        
        self.draggingItem = nil
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal {
        DropProposal(operation: .move)
    }
}

#Preview {
    RoutineEditView()
}
