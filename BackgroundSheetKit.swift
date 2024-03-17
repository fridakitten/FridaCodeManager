import SwiftUI

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Delay setting the background color
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            view.superview?.superview?.backgroundColor = .clear
        }
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}