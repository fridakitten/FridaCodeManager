import SwiftUI

struct WikiView: View {
    var body: some View {
        NavigationView() {
            XMLDetailView(title: "Wiki", filePath: "https://raw.githubusercontent.com/fridakitten/FridaWikiXMLRepo/main/main.xml")
        }
    }
}
