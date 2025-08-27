import SwiftUI

struct HomeView: View {
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                }
                
                Spacer()
                
                 NavigationLink("New Routine") {
                     // routine creation view
                 }
            }
            .padding(.horizontal)
            .buttonStyle(.bordered)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Ready for some exercise?")
                        .font(.largeTitle)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingSettings) { SettingsView() }
    }
}

#Preview {
    HomeView()
}
