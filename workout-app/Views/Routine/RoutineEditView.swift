import SwiftUI

struct RoutineEditView: View {
    @State private var showingNewStepSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var sheetDetent: PresentationDetent = .medium
    @State private var addedStepSummaries: [String] = []
    
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
                List(addedStepSummaries, id: \.self) { summary in
                    Text(summary)
                }
                .listStyle(.insetGrouped)
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
