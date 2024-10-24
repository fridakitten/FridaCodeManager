/*
UIHighlightEngine.swift

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

struct HighlightedTextEditor: UIViewRepresentable {
    
    let navigationBar: UINavigationBar
    let lineNumberLabel: UILabel
    let highlightRules: [HighlightRule]
    let filepath: String
    let filename: String
    @Binding var sheet: Bool
    
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
                sheet = false
            } else {
                print("[*] error to retrieve content\n")
            }
        }

        navigationItem.rightBarButtonItem = saveButton

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
        
        textView.backgroundColor = .clear
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
        
        // Create the "Tab" button
        let tabButton = ClosureBarButtonItem(title: "Tab", style: .plain) {
            insertTextAtCurrentPosition(textView: textView, newText: "\t")
        }
        
        // Create flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Create the line label
        let lineLabel = UILabel()
        lineLabel.text = "Line"
        lineLabel.sizeToFit()
        lineLabel.lineBreakMode = .byWordWrapping
        lineLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create the line number label
        lineNumberLabel.text = "n/a"
        lineNumberLabel.sizeToFit()
        lineNumberLabel.lineBreakMode = .byWordWrapping
        lineNumberLabel.textAlignment = .left
        lineNumberLabel.font = UIFont.boldSystemFont(ofSize: 15) // Make the line number bold
        lineNumberLabel.translatesAutoresizingMaskIntoConstraints = false

        // Create a stack view to hold the line label and line number label
        let stackView = UIStackView(arrangedSubviews: [lineLabel, lineNumberLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4 // Add spacing between "Line" and line number
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // Create a bar button item for the stack view
        let stackItem = UIBarButtonItem(customView: stackView)

        // Add items to the toolbar
        toolbar.items = [tabButton, flexibleSpace, stackItem]

        // Set the text view's delegate to self
        textView.inputAccessoryView = toolbar
        
        // Set content hugging and compression resistance priorities
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
        var parent: HighlightedTextEditor
        var selectedTextRange: UITextRange?
        var updatingUIView = false
        var debounceTimer: Timer?
        var editing: Bool = false

        init(_ markdownEditorView: HighlightedTextEditor) {
            self.parent = markdownEditorView
        }
        
        func runIntrospect(_ textView: UITextView) {
            textView.font = UIFont(name: "Menlo", size: 13.0)
        }
        
        private func getVisibleRange(for textView: UITextView) -> NSRange {
            let layoutManager = textView.layoutManager
            let textContainer = textView.textContainer
            let visibleRect = textView.bounds

            let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: textContainer)

            let startIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
            let endIndex = layoutManager.characterIndexForGlyph(at: NSMaxRange(visibleGlyphRange))
            
            return NSRange(location: startIndex, length: endIndex - startIndex)
        }

        func textViewDidChange(_ textView: UITextView) {
            editing = true
            debounceTimer?.invalidate()
            
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                guard textView.markedTextRange == nil else { return }

                let currentSelectedRange = textView.selectedTextRange
                let visibleRange = self?.getVisibleRange(for: textView) ?? NSRange(location: 0, length: 0)

                self?.applyHighlighting(to: textView, with: visibleRange)

                textView.selectedTextRange = currentSelectedRange

                self?.runIntrospect(textView)
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            gimmetheline(textView)
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            if editing {
                if let textView = scrollView as? UITextView {
                    applyHighlighting(to: textView, with: NSRange(location: 0, length: textView.text.utf16.count))
                    runIntrospect(textView)
                    editing = false
                    textView.endEditing(true)
                }
            }
        }
        
        func applyHighlighting(to textView: UITextView, with visibleRange: NSRange) {
            let fullRange = NSRange(location: 0, length: textView.text.utf16.count)

            textView.textStorage.beginEditing()
            textView.textStorage.addAttribute(.foregroundColor, value: UIColor.label, range: fullRange)

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
func gsuffix(from fileName: String) -> String {
    let trimmedFileName = fileName.replacingOccurrences(of: " ", with: "")
    let suffix = URL(string: trimmedFileName)?.pathExtension
    return suffix ?? ""
}

func grule(_ isaythis: String) -> [HighlightRule] {
   let color1: UIColor = UIColor(red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0)
   let color2: UIColor = UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0)
   let color3: UIColor = UIColor(red: 0.7137, green: 0, blue: 1, alpha: 1.0)
   let color4: UIColor = UIColor(red: 0.7569, green: 0.2039, blue: 0.3882, alpha: 1.0)
   let color5: UIColor = UIColor(red: 0, green: 0.4824, blue: 0.9098, alpha: 1.0)
   let color6: UIColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)

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
