import SwiftUI

struct textset: View {
    @Binding var font: CGFloat
    @Binding var bsl: Bool
    @Binding var fname: String
    var body: some View {
        List {
            Section(header: Text("Font")) {
                FontPickerView(fname: $fname)
                Stepper("Font Size: \(String(Int(font)))", value: $font, in: 0...20)
            }
            Section(header: Text("Appearance")) {
                Toggle("Seperation Layer", isOn: $bsl)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Code Editor")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FontPickerView: View {
    @State private var selectedFontIndex = 0
    @Binding var fname: String
    
    let codeEditorFonts: [String] = guif()
    
    var body: some View {
        VStack {
            Picker(selection: $fname, label: Text("Font")) {
              Group {
ForEach(codeEditorFonts, id: \.self) { fontName in
                    Text(fontName)
                        .font(.custom(fontName, size: 16))
                }
              }
              .navigationBarTitleDisplayMode(.inline)
            }
            .labelsHidden()
            .clipped()
        }
    }
}