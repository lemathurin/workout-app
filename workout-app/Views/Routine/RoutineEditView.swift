import SwiftUI

struct RoutineEditView: View {
    @State private var showingNewStepSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    
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
            NewStepSheet()
                .presentationDetents([.medium])
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
