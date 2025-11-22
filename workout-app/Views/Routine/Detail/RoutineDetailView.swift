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
                        ForEach(routine.steps.sorted(by: { $0.order < $1.order }), id: \.self) { step in
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
                
                // Step content with order number
                switch step.type {
                case .exercise:
                    if let exerciseId = step.exerciseId {
                        let exerciseName = getExerciseName(for: exerciseId)
                        Text("\(step.order). \(exerciseName) - \(step.duration) seconds")
                    } else {
                        Text("\(step.order). Unknown exercise - \(step.duration) seconds")
                    }
                    
                case .rest:
                    Text("\(step.order). Rest - \(step.duration) seconds")
                        .foregroundColor(.secondary)
                    
                case .repeats:
                    if let count = step.count {
                        Text("\(step.order). Repeat \(count) times:")
                            .foregroundColor(.blue)
                    } else {
                        Text("\(step.order). Repeat:")
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            
            // Nested steps for repeats
            if step.type == .repeats, let nestedSteps = step.steps {
                ForEach(nestedSteps.sorted(by: { $0.order < $1.order }), id: \.self) { nestedStep in
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