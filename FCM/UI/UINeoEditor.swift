/*
UINeoEditor.swift

Copyright (C) 2023, 2024 SparkleChan and SeanIsTethered
Copyright (C) 2024 fridakitten

This file is part of FridaCodeManager.

FridaCodeManager is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

FridaCodeManager is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with FridaCodeManager. If not, see <https://www.gnu.org/licenses/>.
*/

// MARK: Code Editor
import SwiftUI
import UIKit
import Foundation

struct NeoEditorHelper: View {
    @Binding var isPresented: Bool
    @Binding var filepath: String
    @State var ready: Bool = false

    var body: some View {
        VStack {
            if ready {
                NeoEditor(isPresented: $isPresented, filepath: filepath)
            }
        }
        .onAppear {
            UIInit(type: 1)
            ready = true
        }
        .onDisappear {
            UIInit(type: 0)
        }
    }
}

struct NeoEditor: UIViewRepresentable {
    let navigationBar: UINavigationBar
    let lineNumberLabel: UILabel
    let highlightRules: [HighlightRule]
    let filepath: String
    let filename: String
    @Binding var sheet: Bool

    let font: UIFont = {
        let bold: Bool = UserDefaults.standard.bool(forKey: "fbold")

        let name: String = UserDefaults.standard.string(forKey: "fontname") ?? "Menlo"

        let size: CGFloat = {
            if let sizeUnwrapped = UserDefaults.standard.value(forKey: "savedfont") as? CGFloat {
                return sizeUnwrapped
            } else {
                return 13.0
            }
        }()

        return UIFont(name: "\(name)\(bold ? "-Bold" : "")", size: size) ?? UIFont.systemFont(ofSize: size)
    }()

    init(
        isPresented: Binding<Bool>,
        filepath: String
    ) {
        _sheet = isPresented

        self.filepath = filepath
        self.filename = {
            if let fileURL = URL(string: filepath) {
                return fileURL.lastPathComponent
            } else {
                return "NULL"
            }
        }()

        self.highlightRules = grule(gsuffix(from: filename))
        navigationBar = UINavigationBar()
        lineNumberLabel = UILabel()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        let navigationItem = UINavigationItem(title: "Code Editor")

        let textView = UITextView()

        let saveButton = ClosureBarButtonItem(title: "Save", style: .plain) {
            if let text = textView.text {
                print("[*] content to save: \(text)\n")
                textView.endEditing(true)
                let fileURL = URL(fileURLWithPath: filepath)
                do {
                    try textView.text.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("File saved successfully at: \(fileURL.path)")
                } catch {
                    print("Failed to write to file: \(error)")
                }
            } else {
                print("[*] error to retrieve content\n")
            }
        }

        let closeButton = ClosureBarButtonItem(title: "Close", style: .plain) {
            sheet = false
        }

        navigationItem.rightBarButtonItem = saveButton
        navigationItem.leftBarButtonItem = closeButton

        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false

        textView.text = {
            do {
                return try String(contentsOfFile: filepath)
            } catch {
                print("[*] illegal filepath, couldnt load content\n")
                sheet = false
                return ""
            }
        }()
        textView.delegate = context.coordinator
        context.coordinator.applyHighlighting(to: textView, with: NSRange(location: 0, length: textView.text.utf16.count))
        context.coordinator.runIntrospect(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(navigationBar)
        containerView.addSubview(textView)

        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        textView.backgroundColor = UIColor.systemGray6
        textView.tintColor = UIColor(Color.primary)
        textView.keyboardType = .asciiCapable
        textView.textContentType = .none
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.layer.shouldRasterize = true
        textView.layer.rasterizationScale = UIScreen.main.scale

        setupToolbar(textView: textView)

        return containerView
    }

    func setupToolbar(textView: UITextView) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let tabButton = ClosureBarButtonItem(title: "Tab", style: .plain) {
            insertTextAtCurrentPosition(textView: textView, newText: "\t")
        }

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let lineLabel = UILabel()
        lineLabel.text = "Line"
        lineLabel.sizeToFit()
        lineLabel.lineBreakMode = .byWordWrapping
        lineLabel.translatesAutoresizingMaskIntoConstraints = false

        lineNumberLabel.text = "n/a"
        lineNumberLabel.sizeToFit()
        lineNumberLabel.lineBreakMode = .byWordWrapping
        lineNumberLabel.textAlignment = .left
        lineNumberLabel.font = UIFont.boldSystemFont(ofSize: 15) // Make the line number bold
        lineNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [lineLabel, lineNumberLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4 // Add spacing between "Line" and line number
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let stackItem = UIBarButtonItem(customView: stackView)

        toolbar.items = [tabButton, flexibleSpace, stackItem]

        textView.inputAccessoryView = toolbar

        lineNumberLabel.setContentHuggingPriority(.required, for: .horizontal)
        lineNumberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    func insertTextAtCurrentPosition(textView: UITextView, newText: String) {
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: newText)
        }
    }

    func updateUIView(_ uiView: UIView, context: Context) { }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: NeoEditor
        var selectedTextRange: UITextRange?
        var updatingUIView = false
        var debounceTimer: Timer?
        var editing: Bool = false

        init(_ markdownEditorView: NeoEditor) {
            self.parent = markdownEditorView
        }

        func runIntrospect(_ textView: UITextView) {
            textView.font = self.parent.font
        }

        private func getCaretLineRange(for textView: UITextView) -> NSRange? {
            guard let textRange = textView.selectedTextRange else {
                return nil
            }

            let caretPosition = textRange.start
            let caretIndex = textView.offset(from: textView.beginningOfDocument, to: caretPosition)

            let text = textView.text as NSString

            let lineRange = text.lineRange(for: NSRange(location: caretIndex, length: 0))

            return lineRange
        }

        func textViewDidChange(_ textView: UITextView) {
            editing = true

            debounceTimer?.invalidate()

            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                guard textView.markedTextRange == nil else { return }

                let currentSelectedRange = textView.selectedTextRange
                let visibleRange = self?.getCaretLineRange(for: textView) ?? NSRange(location: 0, length: 0)

                self?.applyHighlighting(to: textView, with: visibleRange)

                textView.selectedTextRange = currentSelectedRange

                self?.runIntrospect(textView)
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            gimmetheline(textView)
        }

        func applyHighlighting(to textView: UITextView, with visibleRange: NSRange) {
            textView.textStorage.beginEditing()
            textView.textStorage.addAttribute(.foregroundColor, value: UIColor.label, range: visibleRange)

            self.parent.highlightRules.forEach { rule in
                let matches = rule.pattern.matches(in: textView.text, options: [], range: visibleRange)

                matches.forEach { match in
                    rule.formattingRules.forEach { formattingRule in
                        let matchRange = Range<String.Index>(match.range, in: textView.text)!
                        let matchContent = String(textView.text[matchRange])
                        guard let key = formattingRule.key,
                              let calculateValue = formattingRule.calculateValue else { return }

                        textView.textStorage.addAttribute(
                            key,
                            value: calculateValue(matchContent, matchRange),
                            range: match.range
                        )
                    }
                }
            }

            textView.textStorage.endEditing()
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            gimmetheline(textView)
        }

        func gimmetheline(_ textView: UITextView) {
            guard let selectedTextRange = textView.selectedTextRange else {
                parent.lineNumberLabel.text = "Error"
                return
            }

            let characterIndex = textView.offset(from: textView.beginningOfDocument, to: selectedTextRange.start)

            let textBeforeCaret = textView.text.prefix(characterIndex)

            DispatchQueue.global(qos: .userInitiated).async {

                let logicalLineNumber = textBeforeCaret.filter { $0.isNewline }.count + 1
                DispatchQueue.main.async {
                    self.parent.lineNumberLabel.text = "\(logicalLineNumber)"
                }
            }
        }
    }
}

extension UITextView {
   var markedTextNSRange: NSRange? {
       markedTextRange.map { NSRange(location: offset(from: beginningOfDocument, to: $0.start), length: offset(from: $0.start, to: $0.end)) }
   }
}

// MARK: Highlighting Rules
struct TextFormattingRule {
   typealias AttributedKeyCallback = (String, Range<String.Index>) -> Any

   let key: NSAttributedString.Key?
   let calculateValue: AttributedKeyCallback?

   init(key: NSAttributedString.Key, value: Any) {
       self.init(key: key, calculateValue: { _, _ in value })
   }

   init(
       key: NSAttributedString.Key? = nil,
       calculateValue: AttributedKeyCallback? = nil
   ) {
       self.key = key
       self.calculateValue = calculateValue
   }
}

struct HighlightRule {
   let pattern: NSRegularExpression

   let formattingRules: [TextFormattingRule]

   init(pattern: NSRegularExpression, formattingRules: [TextFormattingRule]) {
       self.pattern = pattern
       self.formattingRules = formattingRules
   }
}

// MARK: ClosureBar Button
class ClosureBarButtonItem: UIBarButtonItem {
    private var actionHandler: (() -> Void)?

    init(title: String?, style: UIBarButtonItem.Style, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init()
        self.title = title
        self.style = style
        self.target = self
        self.tintColor = UIColor.label
        self.action = #selector(didTapButton)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @objc private func didTapButton() {
        actionHandler?()
    }
}

// MARK: Highlighting Ruler
func grule(_ isaythis: String) -> [HighlightRule] {
   let color1: UIColor = UIColor(loadColor("C1"))
   let color2: UIColor = UIColor(loadColor("C2"))
   let color3: UIColor = UIColor(loadColor("C3"))
   let color4: UIColor = UIColor(loadColor("C4"))
   let color5: UIColor = UIColor(loadColor("C5"))
   let color6: UIColor = UIColor(loadColor("C6"))

   switch(isaythis) {
       case "swift":
           return [
               HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(let|var|struct|some|import|private|class|nil|return|func|override)\\b", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color1)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\b(let|var|struct|func|class)\\s)\\w+", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color2)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+(?=\\s*(\\(|\\{))", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color2)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "@\\w+[^()]", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color3)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b((Int|UInt|Float)(|8|16|32|64)?|Double|Bool|Character|String|CGFloat|CGRect|CGPoint|Color|UIColor|\\w+_t)\\b", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color3)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?|true|false)\\b", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color4)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color5)
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: color6)
               ])
           ]
       case "c","m","cpp","mm","h","hpp":
           return [
            HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(struct|class|enum|nil|return)\\b", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color1)
            ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+(?=\\s*(\\(|\\{))", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color2)
            ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "@\\w+[^()]", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color3)
            ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(int|short|typedef|long|unsigned|const|float|double|BOOL|bool|char|NSString|CGFloat|CGRect|CGPoint|void|\\w+_t)\\b", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color3)
            ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?|true|false|YES|NO)\\b", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color4)
            ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color5)
            ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [
                TextFormattingRule(key: .foregroundColor, value: color6)
            ])
           ]
       case "html", "plist", "xml", "api","entitlements":
           return [
               HighlightRule(pattern: try! NSRegularExpression(pattern: "<[^>]+>", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0))
               ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
               ])
           ]
       case "sh":
           return [
               HighlightRule(pattern: try! NSRegularExpression(pattern: "(#.*[\\s\\S]*?)", options: []), formattingRules: [
                   TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.4824, blue: 0.9098, alpha: 1.0))
               ])
           ]
       default:
           return []
   }
}
