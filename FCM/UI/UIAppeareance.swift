import SwiftUI

public func UIInit(type: Int) -> Void {
    switch type {
        case 0:
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9)
            let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
            navigationBarAppearance.titleTextAttributes = titleAttributes
            let buttonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
            let backItemAppearance = UIBarButtonItemAppearance()
            backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.label]
            navigationBarAppearance.backButtonAppearance = backItemAppearance
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            return
        case 1:
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            return
        default:
            return
    }
}
