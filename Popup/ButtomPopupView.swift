import SwiftUI

struct BottomPopupView<Content: View>: View {

    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                content
                    .padding(.bottom , geometry.safeAreaInsets.bottom)
                    .background {
VStack {
FluidGradient(blobs: [.orange, .primary, .yellow],
                      highlights: [.orange, .primary, .yellow],
                      speed: 1.0,
                      blur: 0.75)
          .ignoresSafeArea()
          .background(.quaternary)
}
.background(Color(.systemBackground))
                    }
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
            }
            .edgesIgnoringSafeArea([.bottom])
        }
        .animation(.easeOut)
        .transition(.move(edge: .bottom))
    }
}