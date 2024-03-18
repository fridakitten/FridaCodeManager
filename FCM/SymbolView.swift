import SwiftUI
import UIKit

struct SFSymbolView: View {
    var body: some View {
        List {
NavigationLink( destination: SFSymbolListView(symbols: gSFSymbols())) {
                Text("All")
            }
Section(header: Text("categories")) {
NavigationLink( destination: SFSymbolListView(symbols: gcommunication())) {
                Label("Communication",systemImage: "bubble.left.and.bubble.right.fill")
            }
NavigationLink( destination: SFSymbolListView(symbols: gweather())) {
                Label("Weather",systemImage: "cloud.moon.rain.fill")
            }
NavigationLink( destination: SFSymbolListView(symbols: gdevices())) {
                Label("Devices",systemImage: "airpodspro")
            }
NavigationLink( destination: SFSymbolListView(symbols: gconnectivity())) {
                Label("Connectivity",systemImage: "network")
            }
NavigationLink( destination: SFSymbolListView(symbols: gnature())) {
                Label("Nature",systemImage: "leaf.fill")
            }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("SFSymbols")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SFSymbolListView: View {
    @State var symbols: [String]
    var body: some View {
            List(symbols, id: \.self) { symbolName in
                Button( action: {
                    copyToPasteboard(symbolName)
                }){
                    HStack {
                        Image(systemName: symbolName)
                            .frame(width: 30, height: 30)
                        Spacer()
                        Text(symbolName)
                    }
              }
            }
            .navigationBarTitle("SFSymbols")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(InsetGroupedListStyle())
    }
    private func copyToPasteboard(_ symbolName: String) {
        UIPasteboard.general.string = symbolName
    }
}