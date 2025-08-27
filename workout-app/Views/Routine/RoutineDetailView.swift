import SwiftUI
import SwiftData

struct RoutineDetailView: View {
    let routine: Routine
    @Query private var exercises: [Exercise]
    
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
                
                // Routine Steps
                VStack(alignment: .leading, spacing: 12) {
                    Text("Routine Steps")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                            StepView(step: step, exercises: exercises, indentLevel: 0)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .navigationTitle("Routine")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StepView: View {
    let step: RoutineStep
    let exercises: [Exercise]
    let indentLevel: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Indentation
                ForEach(0..<indentLevel, id: \.self) { _ in
                    Text("  ")
                }
                
                // Step content
                switch step.type {
                case .exercise:
                    if let exerciseId = step.exerciseId {
                        let exerciseName = getExerciseName(for: exerciseId)
                        Text("- \(exerciseName) - \(step.duration) seconds")
                    } else {
                        Text("- Unknown exercise - \(step.duration) seconds")
                    }
                    
                case .rest:
                    Text("- rest - \(step.duration) seconds")
                        .foregroundColor(.secondary)
                    
                case .repeats:
                    if let count = step.count {
                        Text("- repeat - \(count) times")
                            .foregroundColor(.blue)
                    } else {
                        Text("- repeat")
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            // Nested steps for repeats
            if step.type == .repeats, let nestedSteps = step.steps {
                ForEach(Array(nestedSteps.enumerated()), id: \.offset) { index, nestedStep in
                    StepView(step: nestedStep, exercises: exercises, indentLevel: indentLevel + 1)
                }
            }
        }
    }
    
    private func getExerciseName(for exerciseId: String) -> String {
        return exercises.first { $0.id == exerciseId }?.getName() ?? exerciseId
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