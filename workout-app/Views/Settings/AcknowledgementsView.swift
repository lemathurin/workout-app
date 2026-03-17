import SwiftUI

struct AcknowledgementsView: View {
    var body: some View {
        List {
            Section {
                Text("First person")
                Text("Second person")
            }
        }
        .navigationTitle("settings.acknowledgements")
        .toolbarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        AcknowledgementsView()
    }
}
