import SwiftUI

struct DumpLogBundleMain: View {
    var body: some View {
        List {
            Button("Dump Log") {
                mainlogSystem.dumpLog()
            }
            Button("Clear Log") {
                mainlogSystem.clearLog()
            }
            Button("Test Print") {
                print("meow meow")
            }
        }
        .navigationTitle("DumpLog")
        .navigationBarTitleDisplayMode(.inline)
    }
}
