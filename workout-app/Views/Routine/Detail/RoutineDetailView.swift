import SwiftData
import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @Query private var exercises: [Exercise]
    @State private var showEditSheet = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Routine Name
                Text("Routine Name")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)

                Text(routine.getName())
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 17)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .cornerRadius(20)
                    .padding(.bottom, 12)

                // Metadata Section
                Text("Details")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    .padding(.bottom, 6)

                VStack(spacing: 0) {
                    MetadataRow(
                        icon: "clock",
                        label: "Duration",
                        value: formatDuration(routine.calculateTotalDuration())
                    )

                    Divider()
                        .padding(.leading, 17)

                    MetadataRow(
                        icon: "figure.strengthtraining.functional",
                        label: "Exercises",
                        value: "\(routine.calculateExerciseCount())"
                    )

                    Divider()
                        .padding(.leading, 17)

                    MetadataRow(
                        icon: "calendar",
                        label: "Created",
                        value: formatDate(routine.metadata.createdAt)
                    )

                    if routine.metadata.updatedAt != routine.metadata.createdAt {
                        Divider()
                            .padding(.leading, 17)

                        MetadataRow(
                            icon: "calendar.badge.clock",
                            label: "Updated",
                            value: formatDate(routine.metadata.updatedAt)
                        )
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .cornerRadius(20)
                .padding(.bottom, 12)

                // Steps Section
                Text("Steps")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                    .padding(.bottom, 6)

                if routine.steps.isEmpty {
                    ContentUnavailableView(
                        "No Steps",
                        systemImage: "figure.walk",
                        description: Text("This routine doesn't have any steps yet")
                    )
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(routine.steps.sorted(by: { $0.order < $1.order }), id: \.id) {
                            step in
                            renderStep(step)
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // showEditSheet = true
                }) {
                    Text("Edit")
                }
            }
        }

    }

    // MARK: - View Builders

    @ViewBuilder
    private func renderStep(_ step: RoutineStep) -> some View {
        switch step.type {
        case .exercise:
            DetailStepRowView(
                stepName: getExerciseName(for: step.exerciseId),
                stepMode: routineStepToStepMode(step)
            )
        case .rest:
            DetailStepRowView(
                stepName: "Rest",
                stepMode: routineStepToStepMode(step)
            )
        case .repeats:
            if let nestedSteps = step.steps, let count = step.count {
                DetailRepeatGroupView(
                    repeatCount: count,
                    steps: nestedSteps,
                    exercises: exercises
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func getExerciseName(for exerciseId: String?) -> String {
        guard let exerciseId = exerciseId else {
            return "Unknown Exercise"
        }
        return exercises.first { $0.id == exerciseId }?.getName() ?? "Unknown Exercise"
    }

    private func routineStepToStepMode(_ step: RoutineStep) -> StepMode {
        switch step.type {
        case .exercise:
            // For exercises, check duration and count to determine mode
            if step.duration > 0 {
                return .exerciseTimed(seconds: step.duration)
            } else if let count = step.count, count > 0 {
                return .exerciseReps(count: count)
            } else {
                return .exerciseOpen
            }
        case .rest:
            if step.duration > 0 {
                return .restTimed(seconds: step.duration)
            } else {
                return .restOpen
            }
        case .repeats:
            // This shouldn't be called for repeat types
            return .exerciseOpen
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds < 60 {
            return "\(seconds)s"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            if remainingSeconds == 0 {
                return "\(minutes)m"
            } else {
                return "\(minutes)m \(remainingSeconds)s"
            }
        } else {
            let hours = seconds / 3600
            let remainingMinutes = (seconds % 3600) / 60
            if remainingMinutes == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(remainingMinutes)m"
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

struct MetadataRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)

            Text(label)
                .font(.callout)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 17)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        let sampleRoutine = Routine(
            name: "Core Crusher"
        )

        RoutineDetailView(routine: sampleRoutine)
            .modelContainer(for: [Routine.self, Exercise.self])
    }
}
