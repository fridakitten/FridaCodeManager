import SwiftUI

struct WikiPlaceholderDestination: View {
    var body: some View {
        Text("TBD")
    }
}

struct WikiView: View {
    var body: some View {
        NavigationView {
            List {
                // TODO: Implement destinations, maybe from an API somehow on https://fridacodemanager.github.io?
                Section {
                    NavigationLink(destination: WikiPlaceholderDestination()) {
                        Text("Introduction")
                    }
                    NavigationLink(destination: WikiPlaceholderDestination()) {
                        Text("Features and Limitations")
                    }
                    NavigationLink(destination: WikiPlaceholderDestination()) {
                        Text("Installation")
                    }
                } header: {
                    Label("Prologue", systemImage: "info.circle")
                }
                Section {
                    NavigationLink(destination: WikiPlaceholderDestination()) {
                        Text("Basic Usage")
                    }
                    NavigationLink(destination: WikiPlaceholderDestination()) {
                        Text("Advanced Usage")
                    }
                } header: {
                    Label("User Guide", systemImage: "text.book.closed")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Wiki")
        }.navigationViewStyle(.stack)
    }
}
