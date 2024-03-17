import SwiftUI

@main
struct MyApp: App {
    @State var hello: UUID = UUID()

    init() {
        if #available(iOS 15.0, *) { 
            let navigationBarAppearance = UINavigationBarAppearance()

navigationBarAppearance.configureWithDefaultBackground() 
    UINavigationBar.appearance().standardAppearance = navigationBarAppearance 
    UINavigationBar.appearance().compactAppearance = navigationBarAppearance 
    UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance 
            let appearance: UITabBarAppearance = UITabBarAppearance()
             UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(hello: $hello)
                .onOpenURL { url in
                    handleSprojFile(url: url)
                }
        }
    }
    func handleSprojFile(url: URL) {
        do {
            // Get the Documents directory URL
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            // Create a destination URL in the Documents directory with the new name
            let targetURL = documentsURL.appendingPathComponent("target.sproj")

            // Copy the file to the destination URL
            try FileManager.default.copyItem(at: url, to: targetURL)

            // Example: Read content from the copied file
            let copiedFileContent = try String(contentsOf: targetURL)
            print("Copied File Content: \(copiedFileContent)")

        } catch {
            print("Error handling .sproj file: \(error.localizedDescription)")
        }
        importProj()
        hello = UUID()
    }
}