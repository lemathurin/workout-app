import SwiftUI

struct DynamicSheet<Content: View>: View {
    var animation: Animation
    var maximized: Bool = false
    @ViewBuilder var content: Content
    @State private var sheetHeight: CGFloat = 0
    var body: some View {
        ZStack {
            content
                .fixedSize(horizontal: false, vertical: !maximized)
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: { newValue in
                    let target = maximized
                        ? maxHeight
                        : min(newValue.height, maxHeight)
                    if sheetHeight == .zero {
                        sheetHeight = target
                    } else {
                        withAnimation(animation) {
                            sheetHeight = target
                        }
                    }
                }
        }
        .onChange(of: maximized) {
            withAnimation(animation) {
                sheetHeight = maximized ? maxHeight : sheetHeight
            }
        }
        .modifier(SheetHeightModifier(height: sheetHeight))
    }
    
    private var maxHeight: CGFloat {
        windowSize.height - 110
    }

    private var windowSize: CGSize {
        if let size = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.screen.bounds.size {
            return size
        }
        return .zero
    }
}

fileprivate struct SheetHeightModifier: ViewModifier, Animatable {
    var height: CGFloat
    var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }
    func body(content: Content) -> some View {
        content
            .presentationDetents(height == .zero ? [.medium] : [.height(height)])
    }
}

#Preview{
    ContentView()
}
