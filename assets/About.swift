import SwiftUI
import UIKit

struct Frida: View {
    @Binding var hello: UUID
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About")) {
                    Text("FridaCodeManager 1.0.1")
                }
                Section(header: Text("Credits")) {
                    cell(credit: "Frida", role: "main deveveloper", url: "https://github.com/fridakitten.png")
                    cell(credit: "AppInstaller iOS", role: "compiling genius", url: "https://github.com/AppInstalleriOSGH.png")
                    cell(credit: "HAHALOSAH", role: "helping hand", url: "https://github.com/HAHALOSAH.png")
                    cell(credit: "MudSplasher", role: "icon designer", url: "https://github.com/MudSplasher.png")
                }
            }
            .id(hello)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(InsetGroupedListStyle())
        }
    }
}