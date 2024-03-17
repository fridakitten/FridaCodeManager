import SwiftUI

struct Settings: View {
    @Binding var sdk: String
    @Binding var font: CGFloat
    @Binding var bsl: Bool
    @Binding var fname: String
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("default sdk"), footer: Text("The sdk gets used when you create a new project.")) {
                    Text(sdk)
                    NavigationLink(destination: SDKList(directoryPath: "var/jb/opt/theos/sdks" ,sdk: $sdk)) {
                        Text("Change")
                    }
                }
                .onChange(of: font) { _ in
                    save()
                }
                Section(header: Text("Advanced")) {
                    NavigationLink(destination: textset(font: $font, bsl: $bsl, fname: $fname)) {
                        Text("Code Editor")
                    }
                }
                Section(header: Text("Additional Tools")) {
                    NavigationLink(destination: SFSymbolView()) {
                    Text("SFSymbols")
                }
                NavigationLink(destination: Packages()) {
                    Text("Frameworks (Experimental)")
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
    func save() {
        UserDefaults.standard.set(font, forKey: "savedfont")
    }
}
