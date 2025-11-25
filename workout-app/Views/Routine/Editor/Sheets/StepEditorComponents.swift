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
    @State private var searchText = ""
    @State private var searchResults: [Exercise] = []

    private var isSearching: Bool {
        return !searchText.isEmpty
    }

    private var displayedExercises: [Exercise] {
        isSearching ? searchResults : exercises
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Search Bar due to .searchable position bug/issue I can't fix
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
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemBackground))
                )
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.vertical, 8)

                List {
                    ForEach(displayedExercises, id: \.id) { exercise in
                        Button {
                            selectedId = exercise.id
                            selectedName = exercise.getName()
                            onDone()
                        } label: {
                            Text(exercise.getName())
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Choose Exercise")
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: searchText) {
                    fetchSearchResults(for: searchText)
                }
                .overlay {
                    if isSearching && searchResults.isEmpty {
                        ContentUnavailableView(
                            "Exercise not found",
                            systemImage: "magnifyingglass",
                            description: Text("No results for **\(searchText)**")
                        )
                    }
                }

                Button {
                    onBack()
                } label: {
                    Text("Back")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .padding()
            }
        }
    }

    private func fetchSearchResults(for query: String) {
        searchResults = exercises.filter { exercise in
            exercise.getName()
                .lowercased()
                .contains(query.lowercased())
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
