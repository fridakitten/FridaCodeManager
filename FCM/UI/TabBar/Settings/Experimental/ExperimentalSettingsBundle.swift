import SwiftUI
import Foundation

struct ExperimentalSettingsBundle: View {
    @AppStorage("CEHighlightCache") var cachehighlightings: Bool = false
    @AppStorage("CETypechecking") var typecheck: Bool = false
    @AppStorage("GIT_ENABLED") var enabled: Bool = false
    @AppStorage("GIT_TOKEN") var token: String = ""
    var body: some View {
        List {
            Section(header: Text("Code Editor")) {
                Toggle("Cache Highlightings", isOn: $cachehighlightings)
                Toggle("Typecheck Code", isOn: $typecheck)
            }
            Section(header: Text("GitHub")) {
                Toggle("Enabled", isOn: $enabled)
                if enabled {
                    SecureField("Token", text: $token)
                }
            }
            NavigationLink(destination: DumpLogBundleMain()) {
                Label("Logging System (DEBUG)", systemImage: "doc.fill")
            }
        }
        .navigationTitle("Experimental")
        .navigationBarTitleDisplayMode(.inline)
    }
}
