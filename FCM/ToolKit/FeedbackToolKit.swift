import UIKit

let generator = UINotificationFeedbackGenerator()

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