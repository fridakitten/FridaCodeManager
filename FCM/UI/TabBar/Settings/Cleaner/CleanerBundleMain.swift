import SwiftUI

struct Cleaner: View {
    var body: some View {
       List {
           Button(action: {
               clean(1)
           }) {
               Label("Clean Module Cache", systemImage: "trash.fill")
           }
           Button(action: {
               clean(2)
           }) {
               Label("Clean Temporary Data", systemImage: "trash.fill")
           }
       }
       .navigationTitle("Cleaner")
       .navigationBarTitleDisplayMode(.inline)
    }

    private func clean(_ arg: Int) {
        DispatchQueue.global(qos: .utility).async {
            ShowAlert(UIAlertController(title: "Cleaning", message: "", preferredStyle: .alert))
                let path: String = {
                    switch(arg) {
                        case 1:
                            return "\(global_documents)/../.cache"
                        case 2:
                            return "\(global_documents)/../tmp"
                        default:
                            return "\(global_documents)/../.cache"
                    }
                }()
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try adv_rm( atPath: path)
                    } catch {
                    }
                }
            DismissAlert()
        }
    }
}
