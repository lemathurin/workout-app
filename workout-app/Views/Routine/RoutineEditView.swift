import SwiftUI

struct RoutineEditView: View {
    @State private var showingNewStepSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var sheetDetent: PresentationDetent = .medium
    
    var body: some View {
        VStack {
            Button(action: {
                showingNewStepSheet = true
            }) {
                Text("Add a step")
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showingNewStepSheet) {
            NewStepSheet(sheetDetent: $sheetDetent)
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
