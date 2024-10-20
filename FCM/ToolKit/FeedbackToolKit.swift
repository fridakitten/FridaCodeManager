import UIKit

let generator = UINotificationFeedbackGenerator()

//Haptic Feedback
public func haptfeedback(_ type: Int) -> Void {
    switch(type) {
        case 1:
            generator.notificationOccurred(.success)
            return
        case 2:
            generator.notificationOccurred(.error)
            return
        default:
            return
    }
}

//Alert Feedback
public func ShowAlert(_ alert: UIAlertController) -> Void {
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

public func DismissAlert() -> Void {
    DispatchQueue.main.async {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let keyWindow = windowScene.keyWindow,
              let rootViewController = keyWindow.rootViewController else {
            return
        }
        
        // Find the topmost view controller to dismiss the alert from
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }
        topController.dismiss(animated: true, completion: nil)
    }
}
