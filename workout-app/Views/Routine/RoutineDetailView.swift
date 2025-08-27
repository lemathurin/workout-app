import SwiftUI
import SwiftData

struct RoutineDetailView: View {
    let routine: Routine
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(routine.getName())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(routine.getDescription() ?? "No description available")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Placeholder content - to be filled later
                VStack {
                    Text("Routine details will be implemented here")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("This will include:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Step-by-step routine breakdown")
                        Text("• Exercise details and instructions")
                        Text("• Timer functionality")
                        Text("• Progress tracking")
                    }
                    .font(.body)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
        }
        .navigationTitle("Routine")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        let sampleRoutine = Routine(
            name: "Core Crusher",
            routineDescription: "A challenging core workout to strengthen your abs and improve stability"
        )
        
        RoutineDetailView(routine: sampleRoutine)
    }
}
