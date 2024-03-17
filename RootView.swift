import SwiftUI

struct ContentView: View {
    @Binding var hello: UUID
    @AppStorage("sdk") var sdk: String = "iPhoneOS15.6.sdk "
    @AppStorage("bsl") var bsl: Bool = true
    @AppStorage("fontname") var fname: String = "Menlo"
    @State private var font: CGFloat = {
        if let savedFont = UserDefaults.standard.value(forKey: "savedfont") as? CGFloat {
            return savedFont
        } else {
            return 15.0
        }
    }()
    var body: some View {
        TabView {
            Home(SDK: $sdk, hellnah: $hello)
            .tabItem {
                Label("Home", systemImage: "house")
            }
            ProjectView(sdk: $sdk, font: $font, hello: $hello)
            .tabItem {
                Label("Projects", systemImage: "folder")
            }
            StatsView()
            .tabItem {
                Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
            }
            Settings(sdk: $sdk, font: $font, bsl: $bsl, fname: $fname)
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .offset(x: 0, y: 0)
        .accentColor(.primary)
    }
}
