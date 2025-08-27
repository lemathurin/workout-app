import SwiftUI
import SwiftData

@main
struct workout_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            // Exercise-related models
            Exercise.self, 
            Equipment.self, 
            Level.self, 
            Force.self, 
            Category.self, 
            Mechanic.self, 
            Muscle.self, 
            Translation.self, 
            ExerciseTranslation.self,
            // Routine-related models
            Routine.self,
            RoutineStep.self,
            RoutineMetadata.self,
            RoutineTranslation.self
        ])
    }
}
