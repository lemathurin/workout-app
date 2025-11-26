import SwiftData
import SwiftUI

struct RoutineCard: View {
    let routine: Routine

    var body: some View {
        NavigationLink(destination: RoutineDetailView(routine: routine)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.getName())
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(routine.calculateTotalDuration()) min")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)

                        Text("\(routine.calculateExerciseCount()) exercises")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                HStack {
                    Text(routine.metadata.difficulty)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)

                    if !routine.metadata.equipment.isEmpty {
                        Text(routine.metadata.equipment.joined(separator: ", "))
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.1))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }

                    Spacer()
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    // Preview with sample data
    let sampleRoutine = Routine(
        name: "Core Crusher",
        steps: []
    )

    RoutineCard(routine: sampleRoutine)
        .padding()
}
