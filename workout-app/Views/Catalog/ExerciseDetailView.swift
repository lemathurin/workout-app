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
            VStack(alignment: .leading, spacing: 20) {
                Text(exercise.getName())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(spacing: 20) {
                    DetailPairRow(
                        leftTitle: "common.equipment", leftValue: getEquipmentName(),
                        rightTitle: "common.level", rightValue: getLevelName()
                    )
                    DetailPairRow(
                        leftTitle: "common.force", leftValue: getForceName(),
                        rightTitle: "common.category", rightValue: getCategoryName()
                    )
                    DetailPairRow(
                        leftTitle: "common.mechanic", leftValue: getMechanicName(),
                        rightTitle: "common.primaryMuscle", rightValue: getPrimaryMuscleName()
                    )
                    
                    if !exercise.secondaryMuscles.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise.secondaryMuscles.count == 1 ? "common.secondaryMuscle" : "common.secondaryMuscles")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(exercise.secondaryMuscles.map { getMuscleName(for: $0) }.joined(separator: ", "))
                                .font(.title2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("exerciseDetails.title")
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

struct DetailPairRow: View {
    let leftTitle: LocalizedStringKey
    let leftValue: String
    let rightTitle: LocalizedStringKey
    let rightValue: String
    
    var body: some View {
        HStack(alignment: .top) {
            DetailCell(title: leftTitle, value: leftValue)
                .frame(maxWidth: .infinity, alignment: .leading)
            DetailCell(title: rightTitle, value: rightValue)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct DetailCell: View {
    let title: LocalizedStringKey
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
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
