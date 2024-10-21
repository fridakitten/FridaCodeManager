import UIKit

public func UIInit(type: Int) -> Void {
    switch type {
        case 0:
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.backgroundColor = UIColor.systemBackground
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
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
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
