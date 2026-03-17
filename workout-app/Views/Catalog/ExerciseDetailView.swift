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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getEquipmentName() -> String {
        equipment.first { $0.id == exercise.equipmentId }?.translations.localizedText(fallback: exercise.equipmentId) ?? exercise.equipmentId
    }
    
    private func getLevelName() -> String {
        levels.first { $0.id == exercise.levelId }?.translations.localizedText(fallback: exercise.levelId) ?? exercise.levelId
    }
    
    private func getForceName() -> String {
        forces.first { $0.id == exercise.forceId }?.translations.localizedText(fallback: exercise.forceId) ?? exercise.forceId
    }
    
    private func getCategoryName() -> String {
        categories.first { $0.id == exercise.categoryId }?.translations.localizedText(fallback: exercise.categoryId) ?? exercise.categoryId
    }
    
    private func getMechanicName() -> String {
        mechanics.first { $0.id == exercise.mechanicId }?.translations.localizedText(fallback: exercise.mechanicId) ?? exercise.mechanicId
    }
    
    private func getPrimaryMuscleName() -> String {
        muscles.first { $0.id == exercise.primaryMuscleId }?.translations.localizedText(fallback: exercise.primaryMuscleId) ?? exercise.primaryMuscleId
    }
    
    private func getMuscleName(for muscleId: String) -> String {
        muscles.first { $0.id == muscleId }?.translations.localizedText(fallback: muscleId) ?? muscleId
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
