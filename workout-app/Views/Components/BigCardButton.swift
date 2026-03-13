import SwiftUI

struct BigCardButton: View {
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity,
               minHeight: 110,
               alignment: .topLeading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    BigCardButton(
        title: "Exercise",
        description: "Perform a specific movement or activity."
    ) {}
    .padding()
    .background(Color(.secondarySystemBackground))
}
