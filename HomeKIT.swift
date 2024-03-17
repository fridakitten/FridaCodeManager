import SwiftUI
import Combine

struct HomeBarHider: UIViewControllerRepresentable {
    class Coordinator: NSObject {
        var cancellable: AnyCancellable?

        deinit {
            cancellable?.cancel()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .clear
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let coordinator = context.coordinator

        coordinator.cancellable = NotificationCenter.default
            .publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { _ in
                // Hide home indicator when app enters the background
                uiViewController.additionalSafeAreaInsets.bottom = -1
            }
    }
}