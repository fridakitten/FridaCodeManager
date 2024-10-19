import SwiftUI

extension View {
    func fcm_navigationview() -> some View {
        self.modifier(InlineNavigationTitleModifier())
    }
}

struct InlineNavigationTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        NavigationView {
            content
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
