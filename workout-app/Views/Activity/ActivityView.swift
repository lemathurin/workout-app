import SwiftUI

struct ActivityView: View {
    var body: some View {
        ContentUnavailableView(
            "activity.title",
            systemImage: "hammer.fill",
            description: Text("activity.description")
        )
    }
}

#Preview {
    ActivityView()
}
