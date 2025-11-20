import SwiftUI
import UniformTypeIdentifiers

/// Reusable drop zone view for drag-and-drop operations
struct DropZoneView<Delegate: DropDelegate>: View {
    let height: CGFloat
    let color: Color
    let delegate: Delegate

    init(height: CGFloat = 12, color: Color = .clear, delegate: Delegate) {
        self.height = height
        self.color = color
        self.delegate = delegate
    }

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .onDrop(of: [.text], delegate: delegate)
    }
}
