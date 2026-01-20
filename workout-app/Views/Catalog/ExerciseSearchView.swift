import SwiftUI
import SwiftData

struct ExerciseSearchView: View {
    @Query private var exercises: [Exercise]
    @Query private var equipment: [Equipment]
    @Query private var levels: [Level]
    @Query private var forces: [Force]
    @Query private var categories: [Category]
    @Query private var mechanics: [Mechanic]
    @Query private var muscles: [Muscle]
    
    @State private var searchText: String = ""
    @State private var showingFilters = false
    
    // Filter states
    @State private var selectedEquipment: Set<String> = []
    @State private var selectedLevel: String?
    @State private var selectedForce: String?
    @State private var selectedCategory: String?
    @State private var selectedMechanic: String?
    @State private var selectedMuscle: String?

    private var hasActiveFilters: Bool {
        !selectedEquipment.isEmpty || selectedLevel != nil || selectedForce != nil
            || selectedCategory != nil || selectedMechanic != nil || selectedMuscle != nil
    }

    private var filteredExercises: [Exercise] {
        var result = exercises
        
        // Apply filters
        if !selectedEquipment.isEmpty {
            result = result.filter { selectedEquipment.contains($0.equipmentId) }
        }
        if let level = selectedLevel {
            result = result.filter { $0.levelId == level }
        }
        if let force = selectedForce {
            result = result.filter { $0.forceId == force }
        }
        if let category = selectedCategory {
            result = result.filter { $0.categoryId == category }
        }
        if let mechanic = selectedMechanic {
            result = result.filter { $0.mechanicId == mechanic }
        }
        if let muscle = selectedMuscle {
            result = result.filter { $0.primaryMuscleId == muscle }
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { exercise in
                exercise.getName().localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result.sorted {
            $0.getName().localizedCaseInsensitiveCompare($1.getName()) == .orderedAscending
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sectionTitles, id: \.self) { letter in
                    Section(header: Text(letter)) {
                        ForEach(groupedExercises[letter] ?? [], id: \.id) { exercise in
                            NavigationLink(value: exercise) {
                                Text(exercise.getName())
                            }
                        }
                    }
                    .sectionIndexLabel(Text(letter))
                }
            }
            .listStyle(.insetGrouped)
            .listSectionIndexVisibility(.visible)
            .navigationTitle("Exercises")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease")
                            if hasActiveFilters {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 4, y: -4)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                ExerciseFilterSheet(
                    equipment: equipment,
                    levels: levels,
                    forces: forces,
                    categories: categories,
                    mechanics: mechanics,
                    muscles: muscles,
                    selectedEquipment: $selectedEquipment,
                    selectedLevel: $selectedLevel,
                    selectedForce: $selectedForce,
                    selectedCategory: $selectedCategory,
                    selectedMechanic: $selectedMechanic,
                    selectedMuscle: $selectedMuscle
                )
            }
        }
        .searchable(text: $searchText, prompt: "Search exercises")
    }

    private var groupedExercises: [String: [Exercise]] {
        Dictionary(grouping: filteredExercises) { exercise in
            String(exercise.getName(for: "en").prefix(1)).uppercased()
        }
    }

    private var sectionTitles: [String] {
        groupedExercises.keys.sorted()
    }
}

#Preview {
    ExerciseSearchView()
}
