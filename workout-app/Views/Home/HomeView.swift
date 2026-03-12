import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var showingSettings = false
    @Query private var routines: [Routine]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack {
                        Text("Ready for some exercise?")
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 30)
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        if !routines.isEmpty {
                            LazyVStack(spacing: 20) {
                                ForEach(routines) { routine in
                                    RoutineCard(routine: routine)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical)
                }
            }
            .background(Color(.secondarySystemBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        showingSettings = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        RoutineEditView()
                    } label: {
                        Label("New Routine", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) { SettingsView() }
    }
}

#Preview {
    let sampleRoutines: [Routine] = [
        {
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
        }(),
        {
            let r = Routine(
                name: "Full Body Stretch",
                steps: [
                    RoutineStep(type: .exercise, exerciseId: "hamstring-stretch", duration: 30, order: 0),
                    RoutineStep(type: .rest, duration: 10, order: 1),
                    RoutineStep(type: .exercise, exerciseId: "quad-stretch", duration: 30, order: 2),
                ]
            )
            r.metadata.stepCount = r.calculateStepCount()
            r.metadata.totalDuration = r.calculateTotalDuration()
            return r
        }(),
        {
            let r = Routine(
                name: "HIIT Blast",
                steps: [
                    RoutineStep(type: .exercise, exerciseId: "burpees", duration: 40, order: 0),
                    RoutineStep(type: .rest, duration: 20, order: 1),
                    RoutineStep(type: .exercise, exerciseId: "jump-squats", duration: 40, order: 2),
                    RoutineStep(type: .rest, duration: 20, order: 3),
                    RoutineStep(type: .exercise, exerciseId: "high-knees", duration: 40, order: 4),
                ]
            )
            r.metadata.equipment = ["Jump rope"]
            r.metadata.stepCount = r.calculateStepCount()
            r.metadata.totalDuration = r.calculateTotalDuration()
            return r
        }(),
    ]

    let container = try! ModelContainer(for: Routine.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    for routine in sampleRoutines {
        container.mainContext.insert(routine)
    }

    return HomeView()
        .modelContainer(container)
}
