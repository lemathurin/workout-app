import SwiftData
import SwiftUI

struct RoutineCard: View {
    let routine: Routine

    private var duration: Int {
        routine.metadata.totalDuration ?? routine.calculateTotalDuration()
    }

    private var exerciseCount: Int {
        routine.metadata.stepCount ?? routine.calculateStepCount()
    }

    var body: some View {
        NavigationLink(destination: RoutineDetailView(routine: routine)) {
            VStack(alignment: .leading, spacing: 12) {
                Text(routine.getName())
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                HStack(spacing: 16) {
                    Label("\(duration) min", systemImage: "clock")
                    Label("\(exerciseCount) exercises", systemImage: "figure.strengthtraining.traditional")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    if routine.metadata.equipment.isEmpty {
                        Image(systemName: "figure.stand")
                        Text("body_only")
                            .lineLimit(1)
                    } else {
                        Image(systemName: "dumbbell")
                        Text(routine.metadata.equipment.joined(separator: ", "))
                            .lineLimit(1)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 15)
            .padding(.horizontal, 17)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .clipShape(.rect(cornerRadius: 12))
        }
        .buttonStyle(.plain)
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
    }
}
