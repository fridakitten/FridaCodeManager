import SwiftUI

struct CodeEditorView: View {
    @Binding var quar: Bool
    @Binding var filePath: String
    @Binding var font: CGFloat
    @State var code: String = " "
    @State var save: Bool = true
    @State var opened: Bool = false
    init(quar: Binding<Bool>,filePath: Binding<String>, font: Binding<CGFloat>) {
        _quar = quar
        _filePath = filePath
        _font = font
        if #available(iOS 15.0, *) { 
            let navigationBarAppearance = UINavigationBarAppearance()

navigationBarAppearance.configureWithDefaultBackground() 
    UINavigationBar.appearance().standardAppearance = navigationBarAppearance 
    UINavigationBar.appearance().compactAppearance = navigationBarAppearance 
    UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
    }
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
// Create a new instance of UINavigationBarAppearance
let navigationBarAppearance = UINavigationBarAppearance()

// Set background color
navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9) // Adjust alpha as needed

// Set title text attributes
let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label] // Using label color
navigationBarAppearance.titleTextAttributes = titleAttributes

// Set button styles
let buttonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Set button color to white
navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes

let backItemAppearance = UIBarButtonItemAppearance()
backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.label] // fix text color
navigationBarAppearance.backButtonAppearance = backItemAppearance

// Apply the appearance to the navigation bar
UINavigationBar.appearance().standardAppearance = navigationBarAppearance
UINavigationBar.appearance().compactAppearance = navigationBarAppearance
UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
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