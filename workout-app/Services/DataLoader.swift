import SwiftData
import Foundation

class DataLoader {
    static let shared = DataLoader()
    
    private init() {}
    
    @MainActor
    func loadInitialData(modelContext: ModelContext) async {
        // Check if data already exists
        let exerciseCount = try? modelContext.fetchCount(FetchDescriptor<Exercise>())
        print("Current exercise count: \(exerciseCount ?? 0)")
        
        if let count = exerciseCount, count > 0 {
            print("Data already loaded, skipping...")
            return // Data already loaded
        }
        
        print("Loading initial data...")
        await loadMetadata(modelContext: modelContext)
        await loadExercises(modelContext: modelContext)
        print("Data loading completed")
    }
    
    @MainActor
    private func loadMetadata(modelContext: ModelContext) async {
        guard let url = Bundle.main.url(forResource: "exercise_metadata", withExtension: "json") else {
            print("Could not find exercise_metadata.json file")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Could not read exercise_metadata.json file")
            return
        }
        
        guard let metadata = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("Could not parse exercise_metadata.json")
            return
        }
        
        print("Loading metadata...")
        
        // Load Equipment
        if let equipmentArray = metadata["equipment"] as? [[String: Any]] {
            print("Loading \(equipmentArray.count) equipment items")
            for equipmentData in equipmentArray {
                if let id = equipmentData["id"] as? String,
                   let translationsData = equipmentData["translations"] as? [String: String] {
                    let translations = translationsData.map { Translation(languageCode: $0.key, text: $0.value) }
                    let equipment = Equipment(id: id, translations: translations)
                    modelContext.insert(equipment)
                }
            }
        }
        
        // Load Levels
        if let levelsArray = metadata["levels"] as? [[String: Any]] {
            print("Loading \(levelsArray.count) levels")
            for levelData in levelsArray {
                if let id = levelData["id"] as? String,
                   let translationsData = levelData["translations"] as? [String: String] {
                    let translations = translationsData.map { Translation(languageCode: $0.key, text: $0.value) }
                    let level = Level(id: id, translations: translations)
                    modelContext.insert(level)
                }
            }
        }
        
        // Load Forces
        if let forcesArray = metadata["forces"] as? [[String: Any]] {
            print("Loading \(forcesArray.count) forces")
            for forceData in forcesArray {
                if let id = forceData["id"] as? String,
                   let translationsData = forceData["translations"] as? [String: String] {
                    let translations = translationsData.map { Translation(languageCode: $0.key, text: $0.value) }
                    let force = Force(id: id, translations: translations)
                    modelContext.insert(force)
                }
            }
        }
        
        // Load Categories
        if let categoriesArray = metadata["categories"] as? [[String: Any]] {
            print("Loading \(categoriesArray.count) categories")
            for categoryData in categoriesArray {
                if let id = categoryData["id"] as? String,
                   let translationsData = categoryData["translations"] as? [String: String] {
                    let translations = translationsData.map { Translation(languageCode: $0.key, text: $0.value) }
                    let category = Category(id: id, translations: translations)
                    modelContext.insert(category)
                }
            }
        }
        
        // Load Mechanics
        if let mechanicsArray = metadata["mechanics"] as? [[String: Any]] {
            print("Loading \(mechanicsArray.count) mechanics")
            for mechanicData in mechanicsArray {
                if let id = mechanicData["id"] as? String,
                   let translationsData = mechanicData["translations"] as? [String: String] {
                    let translations = translationsData.map { Translation(languageCode: $0.key, text: $0.value) }
                    let mechanic = Mechanic(id: id, translations: translations)
                    modelContext.insert(mechanic)
                }
            }
        }
        
        // Load Muscles
        if let musclesArray = metadata["muscles"] as? [[String: Any]] {
            print("Loading \(musclesArray.count) muscles")
            for muscleData in musclesArray {
                if let id = muscleData["id"] as? String,
                   let translationsData = muscleData["translations"] as? [String: String] {
                    let translations = translationsData.map { Translation(languageCode: $0.key, text: $0.value) }
                    let muscle = Muscle(id: id, translations: translations)
                    modelContext.insert(muscle)
                }
            }
        }
        
        do {
            try modelContext.save()
            print("Metadata saved successfully")
        } catch {
            print("Error saving metadata: \(error)")
        }
    }
    
    @MainActor
    private func loadExercises(modelContext: ModelContext) async {
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("Could not find exercises.json file")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Could not read exercises.json file")
            return
        }
        
        guard let exercisesArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("Could not parse exercises.json")
            return
        }
        
        print("Loading \(exercisesArray.count) exercises...")
        
        for exerciseData in exercisesArray {
            if let id = exerciseData["id"] as? String,
               let forceId = exerciseData["forceId"] as? String,
               let levelId = exerciseData["levelId"] as? String,
               let mechanicId = exerciseData["mechanicId"] as? String,
               let equipmentId = exerciseData["equipmentId"] as? String,
               let categoryId = exerciseData["categoryId"] as? String,
               let primaryMuscleId = exerciseData["primaryMuscleId"] as? String {
                
                let secondaryMuscles = exerciseData["secondaryMuscles"] as? [String] ?? []
                
                var exerciseTranslations: [ExerciseTranslation] = []
                if let translationsArray = exerciseData["translations"] as? [[String: Any]] {
                    for translationData in translationsArray {
                        if let languageCode = translationData["languageCode"] as? String,
                           let name = translationData["name"] as? String {
                            exerciseTranslations.append(ExerciseTranslation(languageCode: languageCode, name: name))
                        }
                    }
                }
                
                let exercise = Exercise(
                    id: id,
                    forceId: forceId,
                    levelId: levelId,
                    mechanicId: mechanicId,
                    equipmentId: equipmentId,
                    categoryId: categoryId,
                    primaryMuscleId: primaryMuscleId,
                    secondaryMuscles: secondaryMuscles,
                    translations: exerciseTranslations
                )
                
                modelContext.insert(exercise)
            }
        }
        
        do {
            try modelContext.save()
            print("Exercises saved successfully")
        } catch {
            print("Error saving exercises: \(error)")
        }
    }
}