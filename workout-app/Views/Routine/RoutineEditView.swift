import SwiftUI

struct RoutineEditView: View {
    @State private var showingNewStepSheet: Bool = true
    
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
//                .presentationCornerRadius(50) // Note: Define globally
        }
        
    }
}

#Preview {
    RoutineEditView()
}
