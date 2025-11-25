import SwiftData
import SwiftUI

// MARK: - Exercise Mode Selector

struct ExerciseModeSelector: View {
    let currentMode: ExerciseMode?
    let primaryLabel: String
    let secondaryLabel: String
    let onSelectTimed: () -> Void
    let onSelectReps: () -> Void
    let onSelectOpen: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button {
                onSelectTimed()
            } label: {
                Text("Timed")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                onSelectReps()
            } label: {
                Text("Reps")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                onSelectOpen()
            } label: {
                Text("Open")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                onSecondary()
            } label: {
                Text(secondaryLabel)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
        .padding()
    }
}

// MARK: - Timed Picker

struct TimedPicker: View {
    @Binding var seconds: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(stride(from: 5, through: 600, by: 5))

    var body: some View {
        VStack(spacing: 16) {
            Picker("Seconds", selection: $seconds) {
                ForEach(options, id: \.self) { sec in
                    Text("\(sec) seconds").tag(sec)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button {
                    onSecondary()
                } label: {
                    Text(secondaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onPrimary()
                } label: {
                    Text(primaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Reps Picker

struct RepsPicker: View {
    @Binding var reps: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(1...100)

    var body: some View {
        VStack(spacing: 16) {
            Picker("Reps", selection: $reps) {
                ForEach(options, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button {
                    onSecondary()
                } label: {
                    Text(secondaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onPrimary()
                } label: {
                    Text(primaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Rest Mode Selector

struct RestModeSelector: View {
    let currentMode: RestMode?
    let primaryLabel: String
    let secondaryLabel: String
    let onSelectTimed: () -> Void
    let onSelectOpen: () -> Void
    let onSecondary: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button {
                onSelectTimed()
            } label: {
                Text("Timed")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                onSelectOpen()
            } label: {
                Text("Open")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                onSecondary()
            } label: {
                Text(secondaryLabel)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .controlSize(.large)
        .padding()
    }
}

// MARK: - Rest Timed Picker

struct RestTimedPicker: View {
    @Binding var seconds: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(stride(from: 5, through: 600, by: 5))

    var body: some View {
        VStack(spacing: 16) {
            Picker("Seconds", selection: $seconds) {
                ForEach(options, id: \.self) { sec in
                    Text("\(sec) sec").tag(sec)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button {
                    onSecondary()
                } label: {
                    Text(secondaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onPrimary()
                } label: {
                    Text(primaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Repeat Count Picker

struct RepeatCountPicker: View {
    @Binding var count: Int
    let primaryLabel: String
    let secondaryLabel: String
    let onPrimary: () -> Void
    let onSecondary: () -> Void

    private let options = Array(2...20)

    var body: some View {
        VStack(spacing: 16) {
            Picker("Count", selection: $count) {
                ForEach(options, id: \.self) { value in
                    Text("\(value) times").tag(value)
                }
            }
            .pickerStyle(.wheel)
            HStack {
                Button {
                    onSecondary()
                } label: {
                    Text(secondaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onPrimary()
                } label: {
                    Text(primaryLabel)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .controlSize(.large)
        }
        .padding()
    }
}

// MARK: - Exercise Picker

struct ExercisePickerView: View {
    @Binding var selectedId: String?
    @Binding var selectedName: String?
    let onBack: () -> Void
    let onDone: () -> Void

    @Query private var exercises: [Exercise]
    @Query private var equipment: [Equipment]
    @Query private var levels: [Level]
    @Query private var forces: [Force]
    @Query private var categories: [Category]
    @Query private var mechanics: [Mechanic]
    @Query private var muscles: [Muscle]

    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var showingSearch = false

    // Filter states
    @State private var selectedEquipment: Set<String> = []
    @State private var selectedLevel: String?
    @State private var selectedForce: String?
    @State private var selectedCategory: String?
    @State private var selectedMechanic: String?
    @State private var selectedMuscle: String?

    private var isSearching: Bool {
        return !searchText.isEmpty
    }

    private var hasActiveFilters: Bool {
        !selectedEquipment.isEmpty || selectedLevel != nil || selectedForce != nil
            || selectedCategory != nil || selectedMechanic != nil || selectedMuscle != nil
    }

    private var activeFilterCount: Int {
        selectedEquipment.count + (selectedLevel != nil ? 1 : 0) + (selectedForce != nil ? 1 : 0)
            + (selectedCategory != nil ? 1 : 0) + (selectedMechanic != nil ? 1 : 0)
            + (selectedMuscle != nil ? 1 : 0)
    }

    private var filteredExercises: [Exercise] {
        var result = exercises

        // Only show exercises with English translations
        result = result.filter { exercise in
            exercise.translations.contains { $0.languageCode == "en" }
        }

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
        if isSearching {
            result = result.filter { exercise in
                exercise.getName(for: "en")
                    .lowercased()
                    .contains(searchText.lowercased())
            }
        }

        return result.sorted {
            $0.getName().localizedCaseInsensitiveCompare($1.getName()) == .orderedAscending
        }
    }

    private var groupedExercises: [String: [Exercise]] {
        Dictionary(grouping: filteredExercises) { exercise in
            String(exercise.getName(for: "en").prefix(1)).uppercased()
        }
    }

    private var sectionTitles: [String] {
        groupedExercises.keys.sorted()
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sectionTitles, id: \.self) { letter in
                    Section(header: Text(letter)) {
                        ForEach(groupedExercises[letter] ?? [], id: \.id) { exercise in
                            Button {
                                selectedId = exercise.id
                                selectedName = exercise.getName(for: "en")
                                onDone()
                            } label: {
                                Text(exercise.getName(for: "en"))
                            }
                        }
                    }
                    .sectionIndexLabel(Text(letter))
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.insetGrouped)
            .listSectionIndexVisibility(.visible)
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            showingSearch.toggle()
                            if !showingSearch {
                                searchText = ""
                            }
                        }
                    } label: {
                        Image(systemName: showingSearch ? "xmark.circle.fill" : "magnifyingglass")
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
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
            .overlay(alignment: .top) {
                if showingSearch {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)

                        TextField("Search exercises", text: $searchText)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 17)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                    .glassEffect(.clear.interactive())
                    .cornerRadius(20)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .overlay {
                if filteredExercises.isEmpty {
                    ContentUnavailableView(
                        "No exercises found",
                        systemImage: "dumbbell",
                        description: Text(
                            hasActiveFilters
                                ? "Try adjusting your filters" : "No exercises available")
                    )
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
            .safeAreaInset(edge: .bottom) {
                Button {
                    onBack()
                } label: {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding()
                .background(Color(UIColor.systemBackground))
            }
        }
    }
}

// MARK: - Exercise Filter Sheet

struct ExerciseFilterSheet: View {
    let equipment: [Equipment]
    let levels: [Level]
    let forces: [Force]
    let categories: [Category]
    let mechanics: [Mechanic]
    let muscles: [Muscle]

    @Binding var selectedEquipment: Set<String>
    @Binding var selectedLevel: String?
    @Binding var selectedForce: String?
    @Binding var selectedCategory: String?
    @Binding var selectedMechanic: String?
    @Binding var selectedMuscle: String?

    @Environment(\.dismiss) private var dismiss

    private var hasActiveFilters: Bool {
        !selectedEquipment.isEmpty || selectedLevel != nil || selectedForce != nil
            || selectedCategory != nil || selectedMechanic != nil || selectedMuscle != nil
    }

    // Helper function to get English translation
    private func getEnglishText(_ translations: [Translation], fallback: String) -> String {
        translations.first(where: { $0.languageCode == "en" })?.text.capitalized
            ?? fallback.capitalized
    }

    var body: some View {
        NavigationStack {
            Form {
                // Equipment Section
                Section("Equipment") {
                    ForEach(equipment.sorted(by: { $0.id < $1.id }), id: \.id) { item in
                        Button {
                            if selectedEquipment.contains(item.id) {
                                selectedEquipment.remove(item.id)
                            } else {
                                selectedEquipment.insert(item.id)
                            }
                        } label: {
                            HStack {
                                Text(getEnglishText(item.translations, fallback: item.id))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedEquipment.contains(item.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Level Section
                Section("Level") {
                    ForEach(levels.sorted(by: { $0.id < $1.id }), id: \.id) { item in
                        Button {
                            selectedLevel = selectedLevel == item.id ? nil : item.id
                        } label: {
                            HStack {
                                Text(getEnglishText(item.translations, fallback: item.id))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedLevel == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Force Section
                Section("Force Type") {
                    ForEach(forces.sorted(by: { $0.id < $1.id }), id: \.id) { item in
                        Button {
                            selectedForce = selectedForce == item.id ? nil : item.id
                        } label: {
                            HStack {
                                Text(getEnglishText(item.translations, fallback: item.id))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedForce == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Category Section
                Section("Category") {
                    ForEach(categories.sorted(by: { $0.id < $1.id }), id: \.id) { item in
                        Button {
                            selectedCategory = selectedCategory == item.id ? nil : item.id
                        } label: {
                            HStack {
                                Text(getEnglishText(item.translations, fallback: item.id))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedCategory == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Mechanic Section
                Section("Mechanic") {
                    ForEach(mechanics.sorted(by: { $0.id < $1.id }), id: \.id) { item in
                        Button {
                            selectedMechanic = selectedMechanic == item.id ? nil : item.id
                        } label: {
                            HStack {
                                Text(getEnglishText(item.translations, fallback: item.id))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedMechanic == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Primary Muscle Section
                Section("Primary Muscle") {
                    ForEach(muscles.sorted(by: { $0.id < $1.id }), id: \.id) { item in
                        Button {
                            selectedMuscle = selectedMuscle == item.id ? nil : item.id
                        } label: {
                            HStack {
                                Text(getEnglishText(item.translations, fallback: item.id))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedMuscle == item.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if hasActiveFilters {
                        Button("Clear All") {
                            selectedEquipment.removeAll()
                            selectedLevel = nil
                            selectedForce = nil
                            selectedCategory = nil
                            selectedMechanic = nil
                            selectedMuscle = nil
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    let sampleExercises = [
        Exercise(
            id: "barbell_squat",
            forceId: "push",
            levelId: "beginner",
            mechanicId: "compound",
            equipmentId: "barbell",
            categoryId: "strength",
            primaryMuscleId: "quadriceps",
            secondaryMuscles: ["calves", "glutes", "hamstrings", "lower_back"],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Barbell squat"),
                ExerciseTranslation(languageCode: "fr", name: "Squat barre"),
            ]
        ),
        Exercise(
            id: "pushup",
            forceId: "push",
            levelId: "beginner",
            mechanicId: "compound",
            equipmentId: "body_only",
            categoryId: "strength",
            primaryMuscleId: "chest",
            secondaryMuscles: ["shoulders", "triceps"],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Pushup"),
                ExerciseTranslation(languageCode: "fr", name: "Pushup"),
            ]
        ),
        Exercise(
            id: "plank",
            forceId: "static",
            levelId: "beginner",
            mechanicId: "isolation",
            equipmentId: "body_only",
            categoryId: "strength",
            primaryMuscleId: "abdominals",
            secondaryMuscles: [],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Plank"),
                ExerciseTranslation(languageCode: "fr", name: "Planche"),
            ]
        ),
        Exercise(
            id: "crunch",
            forceId: "pull",
            levelId: "beginner",
            mechanicId: "isolation",
            equipmentId: "body_only",
            categoryId: "strength",
            primaryMuscleId: "abdominals",
            secondaryMuscles: [],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Crunch"),
                ExerciseTranslation(languageCode: "fr", name: "Abdominal"),
            ]
        ),
        Exercise(
            id: "mountain_climber",
            forceId: "pull",
            levelId: "beginner",
            mechanicId: "compound",
            equipmentId: "body_only",
            categoryId: "strength",
            primaryMuscleId: "quadriceps",
            secondaryMuscles: ["chest", "hamstrings", "shoulders"],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Mountain climber"),
                ExerciseTranslation(languageCode: "fr", name: "Mouvement du grimpeur"),
            ]
        ),
        Exercise(
            id: "russian_twist",
            forceId: "pull",
            levelId: "intermediate",
            mechanicId: "compound",
            equipmentId: "body_only",
            categoryId: "strength",
            primaryMuscleId: "abdominals",
            secondaryMuscles: ["lower_back"],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Russian twist"),
                ExerciseTranslation(languageCode: "fr", name: "Torsion russe"),
            ]
        ),
        Exercise(
            id: "cat_stretch",
            forceId: "static",
            levelId: "beginner",
            mechanicId: "isolation",
            equipmentId: "body_only",
            categoryId: "stretching",
            primaryMuscleId: "lower_back",
            secondaryMuscles: ["middle_back", "traps"],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Cat stretch"),
                ExerciseTranslation(languageCode: "fr", name: "Étirement de chat"),
            ]
        ),
    ]

    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, ExerciseTranslation.self,
        configurations: config
    )

    for exercise in sampleExercises {
        container.mainContext.insert(exercise)
    }

    return ExercisePickerView(
        selectedId: .constant(nil),
        selectedName: .constant(nil),
        onBack: {},
        onDone: {}
    )
    .modelContainer(container)
}
