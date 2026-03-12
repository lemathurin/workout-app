import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var showingSettings = false
    @Query private var routines: [Routine]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Ready for some exercise?")
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)

                        // Routines Section
                        if !routines.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Your Routines")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Spacer()
                                }
                                .padding(.horizontal)

                                LazyVStack(spacing: 12) {
                                    ForEach(routines) { routine in
                                        RoutineCard(routine: routine)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gear") {
                        showingSettings = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        RoutineEditView()
                    } label: {
                        Label("New Routine", systemImage: "plus")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) { SettingsView() }
    }
}

#Preview {
    HomeView()
}
