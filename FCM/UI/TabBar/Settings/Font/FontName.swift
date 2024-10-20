import SwiftUI

struct textset: View {
    @Binding var bsl: Bool
    @Binding var fname: String
    @Binding var fontstate: CGFloat
    var body: some View {
        List {
            Section(header: Text("Font")) {
                FontPickerView(fname: $fname)
                Stepper("Font Size: \(String(Int(fontstate)))", value: $fontstate, in: 0...20)
                .onChange(of: fontstate) { _ in
                    save()
                }
            }
            Section(header: Text("Appearance")) {
                Toggle("Seperation Layer", isOn: $bsl)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Code Editor")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() -> Void {
        UserDefaults.standard.set(fontstate, forKey: "savedfont")
    }
}
