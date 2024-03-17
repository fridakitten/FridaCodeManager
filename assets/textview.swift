import SwiftUI

struct CodeEditorView: View {
    @Binding var quar: Bool
    @Binding var filePath: String
    @Binding var font: CGFloat
    @State var code: String = " "
    @State var save: Bool = true
    @State var opened: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                CodeEditorGreat(text: $code, font: font)
                .onAppear {
                    loadCode()
                }
            }
            .navigationBarItems(leading:
                Button("Close") {
                    code = ""
                    quar = false
                }
            )
            .navigationBarItems(trailing:
                Button("Save") {
                    saveCode()
                    hideKeyboard()
                    save = true
                }
                .disabled(save)
            )
            .navigationTitle(findFilename())
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: code) { _ in
            if opened == true {
                save = false
            } else {
                opened = true
            }
        }
    }
    private func loadCode() {
        do {
            code = try! String(contentsOfFile: filePath)
        }
    }
    private func saveCode() {
        do {
            try! code.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
    }
    private func findFilename() -> String {
    if let encodedFilePath = filePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
       let url = URL(string: encodedFilePath) {
        let lastPathComponent = url.lastPathComponent
        let name = lastPathComponent.removingPercentEncoding ?? lastPathComponent
        return name
    }
    return "Untitled"
    }
    func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}