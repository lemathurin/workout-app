import SwiftUI
import SwiftData

@main
struct workout_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Exercise.self, Equipment.self, Level.self, Force.self, Category.self, Mechanic.self, Muscle.self, Translation.self, ExerciseTranslation.self])
    }
}
