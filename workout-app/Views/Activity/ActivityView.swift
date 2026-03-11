import SwiftUI

struct ActivityView: View {
    var body: some View {
        ContentUnavailableView(
            "Coming soon",
            systemImage: "hammer.fill",
            description: Text("We'll let you know when it's ready")
        )
    }
}

#Preview {
    ActivityView()
}
