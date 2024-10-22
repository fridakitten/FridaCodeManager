import SwiftUI

let serialQueue = DispatchQueue.global(qos: .background)
let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height

struct ScreenEmulator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
         guard let screenEmulator = getEmulator() else {
             return UIView()
         }
         _ = getTracker(UnsafeMutableRawPointer(Unmanaged.passUnretained(screenEmulator).toOpaque()))
         return screenEmulator
    }

    func updateUIView(_ uiView: UIView, context: Context) -> Void {
    }
}
