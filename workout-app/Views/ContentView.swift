import SwiftUI
import SwiftData

/// Dummy Enum for DynamicSheet demo
enum Padding: String, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var value: CGFloat {
        switch self {
        case .small: 50
        case .medium: 100
        case .large: 450
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var padding: Padding = .small
    @State private var showSheet: Bool = false
    @State private var showDemoTrayView: Bool = false

    var body: some View {
//         NavigationStack {
//             List {
//                 Button("Show Sheet") {
//                     showSheet.toggle()
//                 }
                
//                 Button("Show Demo Tray View") {
//                     showDemoTrayView.toggle()
//                 }
//             }
//             .navigationTitle("Dynamic Sheet")
//         }
//         .sheet(isPresented: $showSheet) {
// //            Change animation here - smooth, snappy, etc
//             DynamicSheet(animation: .smooth(duration: 0.35, extraBounce: 0)) {
//                 VStack(spacing: 15) {
//                     Text("Hello from the sheet")
//                         .font(.callout)
//                         .fontWeight(.medium)
                    
//                     Picker("", selection: $padding) {
//                         ForEach(Padding.allCases, id: \.rawValue) {
//                             Text($0.rawValue)
//                                 .tag($0)
//                         }
//                     }
//                     .pickerStyle(.segmented)
//                 }
//                 .padding(.horizontal, 30)
//                 .padding(.vertical, padding.value)
//             }
//         }
//         .sheet(isPresented: $showDemoTrayView) {
//             DynamicSheet(animation: .smooth(duration: 0.35, extraBounce: 0)) {
//                 DemoTrayView()
//             }
//         }
        
        TabView {
            Tab("tabBar.home", systemImage: "figure.cooldown") {
                HomeView()
            }
            Tab("tabBar.activity", systemImage: "chevron.up.forward.2") {
                ActivityView()
            }
            Tab(role: .search) {
                ExerciseSearchView()
            }
        }
        .task {
            await DataLoader.shared.loadInitialData(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
