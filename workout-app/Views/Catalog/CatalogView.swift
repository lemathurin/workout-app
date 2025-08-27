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
}
