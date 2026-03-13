import SwiftData
import SwiftUI

enum RoutineSortOption: String, CaseIterable {
    case recentlyPlayed = "Most recent"
    case duration = "Duration"
}

struct HomeView: View {
    @State private var showingSettings = false
    @State private var sortOption: RoutineSortOption = .recentlyPlayed
    @State private var selectedEquipment: String?
    @Query private var routines: [Routine]

    private var hasBodyOnlyRoutines: Bool {
        routines.contains { $0.metadata.equipment.isEmpty || $0.metadata.equipment == ["body_only"] }
    }

    private var allEquipment: [String] {
        let unique = Set(routines.flatMap { $0.metadata.equipment })
            .filter { $0 != "body_only" }
            .sorted()
        if hasBodyOnlyRoutines {
            return ["body_only"] + unique
        }
        return unique
    }

    private var filteredAndSortedRoutines: [Routine] {
        var result = routines

        if let equipment = selectedEquipment {
            if equipment == "body_only" {
                result = result.filter {
                    $0.metadata.equipment.isEmpty || $0.metadata.equipment == ["body_only"]
                }
            } else {
                result = result.filter { $0.metadata.equipment.contains(equipment) }
            }
        }

        switch sortOption {
        case .recentlyPlayed:
            result.sort {
                ($0.metadata.lastPlayedAt ?? .distantPast) > ($1.metadata.lastPlayedAt ?? .distantPast)
            }
        case .duration:
            result.sort {
                ($0.metadata.totalDuration ?? $0.calculateTotalDuration()) <
                ($1.metadata.totalDuration ?? $1.calculateTotalDuration())
            }
        }

        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        Text("Ready for some exercise?")
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 30)
                    .padding(.horizontal)

                    sortAndFilterBar

                    if !filteredAndSortedRoutines.isEmpty {
                        LazyVStack(spacing: 20) {
                            ForEach(filteredAndSortedRoutines) { routine in
                                RoutineCard(routine: routine)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
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

    // MARK: - Sort & Filter Bar

    private var sortAndFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Menu {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(RoutineSortOption.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }
                } label: {
                    Label(sortOption.rawValue, systemImage: "arrow.up.arrow.down")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5), in: .capsule)
                }
                .buttonStyle(.plain)

                if !allEquipment.isEmpty {
                    equipmentFilterChips
                }
            }
            .padding(.horizontal) 
        }
    }

    private var equipmentFilterChips: some View {
        ForEach(allEquipment, id: \.self) { equipment in
            Button {
                withAnimation {
                    selectedEquipment = selectedEquipment == equipment ? nil : equipment
                }
            } label: {
                Text(equipment == "body_only" ? "Body only" : equipment)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(.primary)
                    .background(
                        selectedEquipment == equipment
                        ? Color(.systemGray5)
                        : Color(.clear),
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)
        }
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
