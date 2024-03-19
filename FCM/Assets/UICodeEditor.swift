import SwiftUI
import Foundation
import UIKit

struct CodeEditorGreat: View {
    @Binding var text: String
    @State var font: CGFloat
    @State var rules: [HighlightRule]
    init(text: Binding<String>,font: CGFloat, suffix: String) {
        _text = text
        _font = State(initialValue: font)
        _rules = State(initialValue: grule(suffix))
    }
    @AppStorage("fontname") var fname: String = "Menlo"
    @AppStorage("bsl") var bsl: Bool = true
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
    .ignoresSafeArea()
            HighlightedTextEditor(text: $text, highlightRules: rules)
                .introspect { editor in

    editor.textView.font = UIFont(name: fname, size: font)
    editor.textView.backgroundColor = .clear
    editor.textView.tintColor = UIColor(Color.primary)
if bsl == true {
    editor.textView.layer.shadowColor = 
UIColor.black.cgColor
    editor.textView.layer.shadowRadius = 1
    editor.textView.layer.shadowOpacity = 0.2
    editor.textView.layer.shadowOffset = CGSize(width: 0, height: 1)
}

    editor.textView.keyboardType = .asciiCapable
    
    editor.textView.autocorrectionType = .no
    editor.textView.autocapitalizationType = .none
    
   editor.textView.layoutManager.allowsNonContiguousLayout = false

editor.textView.layer.shouldRasterize = true
editor.textView.layer.rasterizationScale = UIScreen.main.scale
            }
        }
    }
}