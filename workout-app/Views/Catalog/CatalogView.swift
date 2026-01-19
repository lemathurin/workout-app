import SwiftData
import SwiftUI

struct CatalogView: View {
    @Query private var exercises: [Exercise]
    @State private var searchText: String = ""

    var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises
        }
        return exercises.filter { $0.getName().localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            VStack {
                List(filteredExercises, id: \.id) { exercise in
                    NavigationLink(value: exercise) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.getName())
                                .font(.headline)

                            HStack {
                                Text("Level: \(exercise.levelId)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                Text("Category: \(exercise.categoryId)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                     
                }
                
            }
            .navigationTitle("Exercise Catalog")
            .navigationSubtitle("\(filteredExercises.count) exercises")
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Exercise.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let exercises = [
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
            id: "squat",
            forceId: "push",
            levelId: "beginner",
            mechanicId: "compound",
            equipmentId: "body_only",
            categoryId: "stretching",
            primaryMuscleId: "quadriceps",
            secondaryMuscles: ["abductors", "glutes", "hamstrings"],
            translations: [
                ExerciseTranslation(languageCode: "en", name: "Squat"),
                ExerciseTranslation(languageCode: "fr", name: "Squat"),
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
        )
    ]

    for exercise in exercises {
        container.mainContext.insert(exercise)
    }

    return NavigationStack {
        CatalogView()
            .modelContainer(container)
    }
}
