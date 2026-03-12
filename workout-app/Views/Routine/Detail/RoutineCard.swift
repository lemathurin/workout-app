import SwiftData
import SwiftUI

struct RoutineCard: View {
    let routine: Routine

    var body: some View {
        NavigationLink(destination: RoutineDetailView(routine: routine)) {
            HStack {
                
                Text(routine.getName())
            
                Text(
                    "\(routine.metadata.totalDuration ?? routine.calculateTotalDuration()) min"
                )

                Text(
                    "\(routine.metadata.stepCount ?? routine.calculateStepCount()) exercises"
                )
                
                if !routine.metadata.equipment.isEmpty {
                    Text(routine.metadata.equipment.joined(separator: ", "))
                }
            }
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    let sampleRoutine: Routine = {
        let r = Routine(
            name: "Core Crusher",
            steps: [
                RoutineStep(type: .exercise, exerciseId: "plank", duration: 45, order: 0),
                RoutineStep(type: .rest, duration: 15, order: 1),
                RoutineStep(type: .exercise, exerciseId: "crunches", duration: 30, order: 2),
                RoutineStep(type: .rest, duration: 15, order: 3),
                RoutineStep(type: .exercise, exerciseId: "mountain-climbers", duration: 30, order: 4),
            ]
        )
        r.metadata.equipment = ["Kettlebell", "Exercise ball"]
        r.metadata.stepCount = r.calculateStepCount()
        r.metadata.totalDuration = r.calculateTotalDuration()
        return r
    }()

    NavigationStack {
        RoutineCard(routine: sampleRoutine)
            .padding()
            .background(Color(.red).opacity(0.4))
    }
}
