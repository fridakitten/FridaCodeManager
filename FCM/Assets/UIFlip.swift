import SwiftUI

struct FlipView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(180))
    }
}

extension View {
    func flipped() -> some View {
        modifier(FlipView())
    }
}