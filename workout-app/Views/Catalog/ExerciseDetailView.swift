import SwiftUI
import SwiftData

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Query private var equipment: [Equipment]
    @Query private var levels: [Level]
    @Query private var forces: [Force]
    @Query private var categories: [Category]
    @Query private var mechanics: [Mechanic]
    @Query private var muscles: [Muscle]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(exercise.getName())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(title: "Equipment", value: getEquipmentName())
                    DetailRow(title: "Level", value: getLevelName())
                    DetailRow(title: "Force", value: getForceName())
                    DetailRow(title: "Category", value: getCategoryName())
                    DetailRow(title: "Mechanic", value: getMechanicName())
                    DetailRow(title: "Primary Muscle", value: getPrimaryMuscleName())
                    
                    if !exercise.secondaryMuscles.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Secondary Muscles:")
                                .font(.headline)
                            ForEach(exercise.secondaryMuscles, id: \.self) { muscleId in
                                Text("• \(getMuscleName(for: muscleId))")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getEquipmentName() -> String {
        return equipment.first { $0.id == exercise.equipmentId }?.translations.first { $0.languageCode == "en" }?.text ?? exercise.equipmentId
    }
    
    private func getLevelName() -> String {
        return levels.first { $0.id == exercise.levelId }?.translations.first { $0.languageCode == "en" }?.text ?? exercise.levelId
    }
    
    private func getForceName() -> String {
        return forces.first { $0.id == exercise.forceId }?.translations.first { $0.languageCode == "en" }?.text ?? exercise.forceId
    }
    
    private func getCategoryName() -> String {
        return categories.first { $0.id == exercise.categoryId }?.translations.first { $0.languageCode == "en" }?.text ?? exercise.categoryId
    }
    
    private func getMechanicName() -> String {
        return mechanics.first { $0.id == exercise.mechanicId }?.translations.first { $0.languageCode == "en" }?.text ?? exercise.mechanicId
    }
    
    private func getPrimaryMuscleName() -> String {
        return muscles.first { $0.id == exercise.primaryMuscleId }?.translations.first { $0.languageCode == "en" }?.text ?? exercise.primaryMuscleId
    }
    
    private func getMuscleName(for muscleId: String) -> String {
        return muscles.first { $0.id == muscleId }?.translations.first { $0.languageCode == "en" }?.text ?? muscleId
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(title):")
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let exercise = Exercise(
        id: "sample",
        forceId: "push",
        levelId: "beginner",
        mechanicId: "compound",
        equipmentId: "barbell",
        categoryId: "strength",
        primaryMuscleId: "quadriceps",
        secondaryMuscles: ["glutes", "hamstrings"],
        translations: [ExerciseTranslation(languageCode: "en", name: "Sample Exercise")]
    )
    
    ExerciseDetailView(exercise: exercise)
}