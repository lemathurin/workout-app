import SwiftUI
import SwiftData

struct CatalogView: View {
    @Query private var exercises: [Exercise]
    
    var body: some View {
        NavigationView {
            VStack {
                // Debug exercise count
                Text("Exercises loaded: \(exercises.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                List(exercises, id: \.id) { exercise in
                    NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.getName())
                                .font(.headline)
                            
                            HStack {
                                Text("Level: \(exercise.levelId)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("Category: \(exercise.categoryId)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            .navigationTitle("Exercise Catalog")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    
    // Add sample data for preview
    let sampleExercise1 = Exercise(
        id: "pushup",
        forceId: "push",
        levelId: "beginner",
        mechanicId: "compound",
        equipmentId: "body_only",
        categoryId: "strength",
        primaryMuscleId: "chest",
        secondaryMuscles: ["shoulders", "triceps"],
        translations: [ExerciseTranslation(languageCode: "en", name: "Push-up")]
    )
    
    let sampleExercise2 = Exercise(
        id: "squat",
        forceId: "push",
        levelId: "beginner",
        mechanicId: "compound",
        equipmentId: "body_only",
        categoryId: "strength",
        primaryMuscleId: "quadriceps",
        secondaryMuscles: ["glutes", "hamstrings"],
        translations: [ExerciseTranslation(languageCode: "en", name: "Squat")]
    )
    
    container.mainContext.insert(sampleExercise1)
    container.mainContext.insert(sampleExercise2)
    
    return CatalogView()
        .modelContainer(container)
}
