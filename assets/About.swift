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
                Section(header: Text("Credits"), footer: Text("by DekotasTM <3")) {
                    cell(credit: "Frida", role: "main deveveloper", url: "")
                    cell(credit: "AppInstaller iOS", role: "compiling genius", url: "https://github.com/AppInstalleriOSGH.png")
                    cell(credit: "HAHALOSAH", role: "help", url: "https://github.com/HAHALOSAH.png")
                }
                Button("Add Dekotas Repo") {
                    openrepo()
                }
            }
            .id(hello)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(GroupedListStyle())
        }
    }
func openrepo() {
    if let url = URL(string: "sileo://source/https://dekotas.org") {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("App not installed.")
        }
    }
}
}