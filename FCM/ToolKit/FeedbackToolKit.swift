import UIKit

let generator = UINotificationFeedbackGenerator()

// Haptic Feedback with enum for better readability
func haptfeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    generator.notificationOccurred(type)
}

// Alert Feedback
func ShowAlert(_ alert: UIAlertController) -> Void {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            return
        }
        
        // Find the topmost view controller to present the alert from
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        topController.present(alert, animated: true, completion: nil)
    }
}

func DismissAlert(completion: (() -> Void)? = nil) {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            completion?()
            return
        }

        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        
        topController.dismiss(animated: true) {
            completion?()
        }
    }
}

func showAlert(with message: String) {
    // Create the alert controller
    let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)

    // Create the OK action
    let okAction = UIAlertAction(title: "Close", style: .default, handler: nil)

    // Add the action to the alert
    alert.addAction(okAction)

    // Present the alert
    ShowAlertAdv(alert)

    haptfeedback(.success)
}

func ShowAlertAdv(_ alert: UIAlertController) {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            return
        }
        
        // Find the topmost view controller to present the alert from
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        topController.present(alert, animated: true, completion: nil)
    }
}
