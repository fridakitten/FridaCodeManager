import SwiftUI
import Foundation
import UIKit

struct CodeEditorGreat: View {
    @Binding var text: String
    @State var font: CGFloat
    @State private var rules: [HighlightRule] = [
         HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\.)\\w+(?=[(])", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(let|var|struct|some|import|private|class|nil|return|func|override)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor (red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\b(let|var|struct|func|class|func)\\s)\\w+", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "@\\w+[^()]", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.7137, green: 0, blue: 1, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+\\s*(?=\\{)", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b((Int|UInt)(|8|16|32|64)?|Float|Double|Bool|Character|String|CGFloat|CGRect|CGPoint|\\w+_t)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.7137, green: 0, blue: 1, alpha: 1.0)) 
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?|true|false)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.7569, green: 0.2039, blue: 0.3882, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.4824, blue: 0.9098, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        ])
    ]
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