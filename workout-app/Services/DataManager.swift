import SwiftData
import Foundation

@MainActor
class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private init() {}
    
    /// Deletes all stored exercise data from the database
    /// - Parameter modelContext: The SwiftData model context
    /// - Throws: Database errors if deletion fails
    func deleteAllData(from modelContext: ModelContext) throws {
        // Delete all exercises
        try modelContext.delete(model: Exercise.self)
        
        // Delete all related metadata
        try modelContext.delete(model: Equipment.self)
        try modelContext.delete(model: Level.self)
        try modelContext.delete(model: Force.self)
        try modelContext.delete(model: Category.self)
        try modelContext.delete(model: Mechanic.self)
        try modelContext.delete(model: Muscle.self)
        
        // Save the changes
        try modelContext.save()
        
        print("All data deleted successfully")
    }
    
    /// Reloads initial data after deletion
    /// - Parameter modelContext: The SwiftData model context
    func reloadInitialData(from modelContext: ModelContext) async {
        await DataLoader.shared.loadInitialData(modelContext: modelContext)
    }
}