import SwiftData
import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @Query private var exercises: [Exercise]
    @State private var showEditView = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                Text(routine.getName())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .frame(maxWidth: .infinity, alignment: .leading)
                //                    .padding(.vertical, 15)

                HStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Steps")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(
                            (routine.metadata.stepCount ?? routine.calculateStepCount()).description
                        )
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading) {
                        Text("Duration")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(
                            formatDuration(
                                routine.metadata.totalDuration ?? routine.calculateTotalDuration())
                        )
                        .font(.title2)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                    }

                    VStack(alignment: .leading) {
                        Text("Created")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(formatDate(routine.metadata.createdAt))
                            .font(.title2)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                    }

                    //                    if routine.metadata.updatedAt != routine.metadata.createdAt {
                    //                        VStack(alignment: .leading) {
                    //                            Text("Created")
                    //                                .font(.subheadline)
                    //
                    //                            Text(formatDate(routine.metadata.updatedAt))
                    //                                .font(.title2)
                    //                                .fontDesign(.rounded)
                    //                                .fontWeight(.semibold)
                    //                        }
                    //                    }

                    Spacer()
                }

                if routine.steps.isEmpty {
                    ContentUnavailableView(
                        "No Steps",
                        systemImage: "figure.walk",
                        description: Text("This routine doesn't have any steps yet")
                    )
                    .padding(.vertical, 200)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditView = true

                }) {
                    Text("Edit")
                }
            }
        }
        .fullScreenCover(isPresented: $showEditView) {
            RoutineEditView(routine: routine)
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
