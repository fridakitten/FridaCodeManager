import UIKit

let generator = UINotificationFeedbackGenerator()

//Haptic Feedback
func haptfeedback(_ type: Int) {
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
func ShowAlert(_ Alert: UIAlertController) {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(Alert, animated: true, completion: nil)
    }
}
func DismissAlert() {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
    }
}