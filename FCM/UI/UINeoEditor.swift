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


// MARK: Code Editor
import SwiftUI
import UIKit
import Foundation

// configuration for NeoEditor
struct NeoEditorConfig {
    var background: UIColor
    var selection: UIColor
    var current: UIColor
    var standard: UIColor
    var font: UIFont
}

struct NeoEditor: UIViewRepresentable {
    
    private let navigationBar: UINavigationBar
    private let navigationItem: UINavigationItem
    private let containerView: UIView
    private let textView: CustomTextView
    private let highlightRules: [HighlightRule]
    private let filepath: String
    private let filename: String

    // not checking over and over again, please no, we dont wanna do the yandere dev!
    private let config: NeoEditorConfig = {
        let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        
        var meow: NeoEditorConfig = NeoEditorConfig(background: UIColor.clear, selection: UIColor.clear, current: UIColor.clear, standard: UIColor.clear, font: UIFont.systemFont(ofSize: 10.0))
        
        meow.font = UIFont.monospacedSystemFont(ofSize: CGFloat(UserDefaults.standard.double(forKey: "CEFontSize")), weight: UIFont.Weight.medium)
        
        if userInterfaceStyle == .light {
            meow.background = light_background
            meow.selection = light_selection
            meow.current = light_current
            meow.standard = light_standard
        } else {
            meow.background = dark_background
            meow.selection = dark_selection
            meow.current = dark_current
            meow.standard = dark_standard
        }
        
        return meow
    }()
    
    @Binding private var sheet: Bool
    private var render: Double
    private var toolbar: Bool
    private var current_line_highlighting: Bool
    
    init(
        isPresented: Binding<Bool>,
        filepath: String
    ) {
        _sheet = isPresented
        
        self.filepath = filepath
        self.filename = {
            let fileURL = URL(fileURLWithPath: filepath)
            return fileURL.lastPathComponent
        }()
        
        self.highlightRules = grule(gsuffix(from: filename))
        navigationBar = UINavigationBar()
        navigationItem = UINavigationItem(title: filename)
        self.render = {
            return UserDefaults.standard.double(forKey: "CERender")
        }()
        self.toolbar = {
            return UserDefaults.standard.bool(forKey: "CEToolbar")
        }()
        self.current_line_highlighting = {
            return UserDefaults.standard.bool(forKey: "CECurrentLineHighlighting")
        }()
        self.containerView = UIView()
        self.textView = CustomTextView()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let saveButton = ClosureBarButtonItem(title: "Save", style: .plain) {
            textView.endEditing(true)
            let fileURL = URL(fileURLWithPath: filepath)
            do {
                try textView.text.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
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

        textView.backgroundColor = config.background
        textView.tintColor = config.selection
        textView.textColor = config.standard
        textView.lineLight = config.current.cgColor
        if current_line_highlighting {
            textView.setupHighlightLayer()
        }
        textView.keyboardType = .asciiCapable
        textView.textContentType = .none
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layoutManager.allowsNonContiguousLayout = true
        textView.layer.shouldRasterize = true
        textView.layer.rasterizationScale = UIScreen.main.scale * CGFloat(render)
        textView.isUserInteractionEnabled = true
        textView.layoutManager.addTextContainer(textView.textContainer)
        textView.layoutManager.ensureLayout(for: textView.textContainer)

        textView.setLayoutCompletionHandler {
            for item in errorcache {
                if item.file == filepath {
                    switch item.level {
                        case 0:
                            textView.highlightLine(at: item.line - 1, with: UIColor.systemBlue, with: item.description, with: "info.circle.fill")
                            break
                        case 1:
                            textView.highlightLine(at: item.line - 1, with: UIColor.systemYellow, with: item.description, with: "exclamationmark.triangle.fill")
                            break
                        case 2:
                            textView.highlightLine(at: item.line - 1, with: UIColor.systemRed, with: item.description, with: "xmark.circle.fill")
                            break
                        default:
                            break
                    }
                }
            }
        }

        if toolbar {
            setupToolbar(textView: textView)
        }

        return containerView
    }

    // basically the toolbar
    func setupToolbar(textView: UITextView) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let tabButton = ClosureBarButtonItem(title: "Tab", style: .plain) {
            insertTextAtCurrentPosition(textView: textView, newText: "\t")
        }
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [tabButton, flexibleSpace]
        textView.inputAccessoryView = toolbar
        //lineNumberLabel.setContentHuggingPriority(.required, for: .horizontal)
        //lineNumberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
        
    // function to insert content to the textView
    func insertTextAtCurrentPosition(textView: UITextView, newText: String) {
        if let selectedRange = textView.selectedTextRange {
            textView.replace(selectedRange, withText: newText)
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: NeoEditor
        var currentRange: NSRange?
        var updatingUIView = false
        private var highlightCache: [NSRange: [NSAttributedString.Key: Any]] = [:]

        init(_ markdownEditorView: NeoEditor) {
            // getting parent
            self.parent = markdownEditorView
        }
        
        func runIntrospect(_ textView: UITextView) {
            textView.font = parent.config.font
        }

        func textViewDidChange(_ textView: UITextView) {
            // getting/converting (to) CustomTextView
            guard let textView = textView as? CustomTextView else { return }
            
            // cheking if the user did paste
            if textView.didPasted {
                // re-applying highlighting to the entire file to ensure that the pasted content is highlighted
                self.applyHighlighting(to: textView, with: NSRange(location: 0, length: textView.text.utf16.count))

                // resetting variable to avoid recalling
                textView.didPasted = false
            } else {
                // applying single-line highlighting
                self.applyHighlighting(to: textView, with: textView.cachedLineRange ?? NSRange(location: 0, length: 0))
            }
        }
        
        func applyHighlighting(to textView: UITextView, with visibleRange: NSRange) {
            // Getting text for background thread processing
            let text = textView.text ?? ""

            DispatchQueue.global(qos: .userInitiated).async {
                var attributesToApply = [(NSRange, NSAttributedString.Key, Any)]()
                self.parent.highlightRules.forEach { rule in
                    let matches = rule.pattern.matches(in: text, options: [], range: visibleRange)
                    matches.forEach { match in
                        let matchRange = match.range
                        
                        // Check if the match is already cached
                        if let cachedAttributes = self.highlightCache[matchRange] {
                            // Use cached attributes
                            for (key, value) in cachedAttributes {
                                attributesToApply.append((matchRange, key, value))
                            }
                            return
                        }

                        // Check for overlapping ranges
                        let isOverlapping = attributesToApply.contains { (range, _, _) in
                            NSIntersectionRange(range, matchRange).length > 0
                        }
                        guard !isOverlapping else { return }
                        
                        rule.formattingRules.forEach { formattingRule in
                            guard let key = formattingRule.key,
                                  let calculateValue = formattingRule.calculateValue else { return }
                            if let matchRangeStr = Range(match.range, in: text) {
                                let matchContent = String(text[matchRangeStr])
                                let value = calculateValue(matchContent, matchRangeStr)

                                // Store the result in the cache
                                self.highlightCache[matchRange] = [key: value]
                                attributesToApply.append((match.range, key, value))
                            }
                        }
                    }
                }
                
                // Update the text storage with the attributes
                DispatchQueue.main.async {
                    textView.textStorage.beginEditing()
                    textView.textStorage.addAttribute(.foregroundColor, value: self.parent.config.standard, range: visibleRange)
                    attributesToApply.forEach { (range, key, value) in
                        textView.textStorage.addAttribute(key, value: value, range: range)
                    }
                    textView.textStorage.endEditing()
                }
            }
        }

        
        func textViewDidBeginEditing(_ textView: UITextView) {
            guard let textView = textView as? CustomTextView else { return }
            textView.enableHighlightLayer()
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            guard let textView = textView as? CustomTextView else { return }
            textView.disableHighlightLayer()
        }
    }
}

class CustomTextView: UITextView {
    var didPasted: Bool = false
    var lineLight: CGColor = UIColor.clear.cgColor
    
    private(set) var hightlight_setuped: Bool = false
    private(set) var cachedLineRange: NSRange?
    private let highlightLayer = CAShapeLayer()
    
    override func paste(_ sender: Any?) {
        didPasted = true
        super.paste(sender)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        let caretRect = super.caretRect(for: position)
        updateCurrentLineRange()
        return caretRect
    }
    
    func setupHighlightLayer() {
        highlightLayer.fillColor = lineLight
        layer.insertSublayer(highlightLayer, at: 0)
        hightlight_setuped = true
    }
    
    private func updateCurrentLineRange() {
        guard let caretPosition = selectedTextRange?.start else {
            return
        }
        
        let caretIndex = offset(from: beginningOfDocument, to: caretPosition)
        let text = self.text as NSString
        let lineRange = text.lineRange(for: NSRange(location: caretIndex, length: 0))

        // this always runs, no matter the check, mostlikely because of location being always offset
        cachedLineRange = lineRange
        
        if hightlight_setuped {
            updateHighlightLayer()
        }
    }
    
    private func updateHighlightLayer() {
        guard let currentLineRange = cachedLineRange else {
            highlightLayer.path = nil
            return
        }

        let path = UIBezierPath()

        layoutManager.enumerateLineFragments(forGlyphRange: currentLineRange) { (rect, usedRect, _, glyphRange, _) in
            let textRect = usedRect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)
            path.append(UIBezierPath(roundedRect: textRect, cornerRadius: 4.0))
        }

        animateHighlightLayer(from: highlightLayer.path, to: path.cgPath)

        highlightLayer.path = path.cgPath
    }

    private var wempty: Bool = false
    private func animateHighlightLayer(from oldPath: CGPath?, to newPath: CGPath) {
        let oldBounds = oldPath?.boundingBox ?? .zero
        let newBounds = newPath.boundingBox

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.25

        animation.toValue = newPath
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false

        if newPath.boundingBox.isEmpty && !wempty {
            animation.keyPath = "opacity"
            animation.fromValue = 1.0
            animation.toValue = 0.0
            animation.duration = 0.50
            wempty = true
            highlightLayer.add(animation, forKey: nil)
        } else if wempty && !newPath.boundingBox.isEmpty {
            animation.keyPath = "opacity"
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 0.50
            wempty = false
        }

        if wempty {
            return
        }

        highlightLayer.add(animation, forKey: nil)
    }

    func enableHighlightLayer() {
        if hightlight_setuped {
            setupHighlightLayer()
        }
    }
    
    func disableHighlightLayer() {
        if hightlight_setuped {
            highlightLayer.removeFromSuperlayer()
        }
    }

    func visualRangeRect(in textView: UITextView, for textRange: NSRange) -> CGRect? {
        guard textRange.location != NSNotFound,
              textRange.location + textRange.length <= textView.textStorage.length else {
            return nil
        }

        // methode 2
        let beginning: UITextPosition = textView.beginningOfDocument;
        guard let start: UITextPosition = textView.position(from: beginning, offset: textRange.location) else { return nil }
        guard let end: UITextPosition = textView.position(from: start, offset: textRange.length) else { return nil }
        guard let textRange: UITextRange = textView.textRange(from: start, to: end) else { return nil }
        
        let rect: CGRect = textView.firstRect(for: textRange)

        return rect
    }

    func rangeOfLine(in string: String, lineNumber: Int) -> NSRange? {
        let nsString = string as NSString
        let lines = nsString.components(separatedBy: .newlines)
        guard lineNumber >= 0 && lineNumber < lines.count else {
            return nil
        }
        var location = 0
        for i in 0..<lineNumber {
            location += (lines[i] as NSString).length + 1
        }
        let length = (lines[lineNumber] as NSString).length
        return NSRange(location: location, length: length)
    }
    
    private func addPath(for range: NSRange, color: UIColor, rect: CGRect) {
        let newHighlightLayer = CAShapeLayer()
        newHighlightLayer.fillColor = color.cgColor
        layer.insertSublayer(newHighlightLayer, at: 0)

        let path = UIBezierPath()
        
        var newRect: CGRect = rect
        newRect.size.width = UIScreen.main.bounds.size.width
        path.append(UIBezierPath(rect: newRect))

        newHighlightLayer.path = path.cgPath
    }
    
    func highlightLine(at lineNumber: Int, with color: UIColor, with text: String, with symbol: String) {
        guard let range = rangeOfLine(in: self.text, lineNumber: lineNumber) else { return }
        guard let rect = visualRangeRect(in: self, for: range) else { return }

        addPath(for: range, color: color.withAlphaComponent(0.3), rect: rect)
            
            let button = ClosureButton(title: "") {
                showAlert(with: text)
            }
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            let image = UIImage(systemName: symbol, withConfiguration: symbolConfig)
            button.setImage(image, for: .normal)
            button.tintColor = color
            button.backgroundColor = .clear
            
            var lineRect: CGRect = .zero
            layoutManager.enumerateLineFragments(forGlyphRange: range) { (rect, _, _, _, _) in
                lineRect = rect.offsetBy(dx: self.textContainerInset.left, dy: self.textContainerInset.top)
            }
            
            let buttonWidth: CGFloat = font?.pointSize ?? 0.0
            let buttonHeight: CGFloat = font?.pointSize ?? 0.0
            let buttonX = (UIScreen.main.bounds.width - 5) - (font?.pointSize ?? 0.0)
            let buttonY = lineRect.midY - (buttonHeight / 2)
            
            button.frame = CGRect(x: buttonX, y: buttonY, width: buttonWidth, height: buttonHeight)

            print("Button frame: \(button.frame)")

            self.addSubview(button)
            bringSubviewToFront(button)
    }
    
    var onLayoutCompletion: (() -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayoutCompletion?()
        onLayoutCompletion = nil
    }

    func setLayoutCompletionHandler(_ handler: @escaping () -> Void) {
        self.onLayoutCompletion = handler
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

class ClosureButton: UIButton {
    private var actionHandler: (() -> Void)?

    init(title: String, actionHandler: @escaping () -> Void) {
        self.actionHandler = actionHandler
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        self.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        self.tintColor = UIColor.label
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
    let userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
    
    var color1: UIColor = UIColor.clear   // Keywords
    var color2: UIColor = UIColor.clear   // Structure or Class Name
    var color4: UIColor = UIColor.clear   // Numbers
    var color5: UIColor = UIColor.clear   // Comments
    var color6: UIColor = UIColor.clear   // Strings
    var color7: UIColor = UIColor.clear   // Functions
    var color8: UIColor = UIColor.clear   // Function/Variable names
    var color10: UIColor = UIColor.clear  // Preprocessor Statements
    
    if userInterfaceStyle == .light {
        color1 = light_color1
        color2 = light_color2
        color4 = light_color4
        color5 = light_color5
        color6 = light_color6
        color7 = light_color7
        color8 = light_color8
        color10 = light_color10
    } else {
        color1 = dark_color1
        color2 = dark_color2
        color4 = dark_color4
        color5 = dark_color5
        color6 = dark_color6
        color7 = dark_color7
        color8 = dark_color8
        color10 = dark_color10
    }

    switch(isaythis) {
        case "swift":
            return [
                HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color6)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color5)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(let|var|if|else|func|return|class|struct|self|public|private|extension|true|false|init|try|do|catch|guard|import|override|nil|switch|case|default|some|throw|for|in)\\b", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color1)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: #"(?<=: |-> |some )[A-Za-z0-9]+"#, options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color7)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\b(struct|class|extension)\\s)\\w+", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color2)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?)\\b", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color4)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\b(func|let|var)\\s)\\w+", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color8)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+(?=(\\())", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color7)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "@\\w+[^()]", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color7)])
            ]
        case "c", "h":
            return [
                HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color6)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(<(.*?)>)", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color6)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color5)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+(?=(\\())", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color8)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\W|^)(#include|#import|#define|#undef|#ifdef|#ifndef|#if|#else|#elif|#endif|#error|#pragma|#line)(?=\\W|$)", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color10)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: #"\b\w*_t\b"#, options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color7)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(int|char|float|double|void|short|long|unsigned|signed|struct|union|enum|_Bool|_Complex|_Imaginary|if|else|switch|case|default|while|do|for|break|continue|return|goto|auto|register|static|extern|typedef|sizeof|const|volatile|restrict|inline|_Alignas|_Alignof|_Atomic|_Static_assert|_Noreturn|_Thread_local)\\b", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color1)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+(?=(\\())", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color8)
                ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?)\\b", options: []), formattingRules: [ TextFormattingRule(key: .foregroundColor, value: color4)
                ])
            ]
        default:
            return []
    }
}

// MARK: Theming
// XCode format
// 1: Keywords
// 2: Type Declarations
// 4: Numbers
// 5: Comments
// 6: Strings
// 7: Other Class Names
// 8: Other Declarations
// 10: Project Preprocessor Macros

// MARK: Color Storage
// Light Color storage
var light_color1: UIColor = UserDefaults.standard.color(forKey: "lc1")
var light_color2: UIColor = UserDefaults.standard.color(forKey: "lc2")
var light_color4: UIColor = UserDefaults.standard.color(forKey: "lc4")
var light_color5: UIColor = UserDefaults.standard.color(forKey: "lc5")
var light_color6: UIColor = UserDefaults.standard.color(forKey: "lc6")
var light_color7: UIColor = UserDefaults.standard.color(forKey: "lc7")
var light_color8: UIColor = UserDefaults.standard.color(forKey: "lc8")
var light_color10: UIColor = UserDefaults.standard.color(forKey: "lc10")

// Dark Color storage
var dark_color1: UIColor = UserDefaults.standard.color(forKey: "dc1")
var dark_color2: UIColor = UserDefaults.standard.color(forKey: "dc2")
var dark_color4: UIColor = UserDefaults.standard.color(forKey: "dc4")
var dark_color5: UIColor = UserDefaults.standard.color(forKey: "dc5")
var dark_color6: UIColor = UserDefaults.standard.color(forKey: "dc6")
var dark_color7: UIColor = UserDefaults.standard.color(forKey: "dc7")
var dark_color8: UIColor = UserDefaults.standard.color(forKey: "dc8")
var dark_color10: UIColor = UserDefaults.standard.color(forKey: "dc10")

var light_standard: UIColor = UserDefaults.standard.color(forKey: "lst")
var light_background: UIColor = UserDefaults.standard.color(forKey: "lb")
var light_selection: UIColor = UserDefaults.standard.color(forKey: "ls")
var light_current: UIColor = UserDefaults.standard.color(forKey: "lcl")
var light_cursor: UIColor = UserDefaults.standard.color(forKey: "lc")

var dark_standard: UIColor = UserDefaults.standard.color(forKey: "dst")
var dark_background: UIColor = UserDefaults.standard.color(forKey: "db")
var dark_selection: UIColor = UserDefaults.standard.color(forKey: "ds")
var dark_current: UIColor = UserDefaults.standard.color(forKey: "dcl")
var dark_cursor: UIColor = UserDefaults.standard.color(forKey: "dc")

// MARK: Theme system
func neoRGB(_ red: CGFloat,_ green: CGFloat,_ blue: CGFloat ) -> UIColor {
    return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
}

func storeTheme() -> Void {
    UserDefaults.standard.setColor(light_color1, forKey: "lc1")
    UserDefaults.standard.setColor(light_color2, forKey: "lc2")
    UserDefaults.standard.setColor(light_color4, forKey: "lc4")
    UserDefaults.standard.setColor(light_color5, forKey: "lc5")
    UserDefaults.standard.setColor(light_color6, forKey: "lc6")
    UserDefaults.standard.setColor(light_color7, forKey: "lc7")
    UserDefaults.standard.setColor(light_color8, forKey: "lc8")
    UserDefaults.standard.setColor(light_color10, forKey: "lc10")
    
    UserDefaults.standard.setColor(dark_color1, forKey: "dc1")
    UserDefaults.standard.setColor(dark_color2, forKey: "dc2")
    UserDefaults.standard.setColor(dark_color4, forKey: "dc4")
    UserDefaults.standard.setColor(dark_color5, forKey: "dc5")
    UserDefaults.standard.setColor(dark_color6, forKey: "dc6")
    UserDefaults.standard.setColor(dark_color7, forKey: "dc7")
    UserDefaults.standard.setColor(dark_color8, forKey: "dc8")
    UserDefaults.standard.setColor(dark_color10, forKey: "dc10")
    
    UserDefaults.standard.setColor(light_standard, forKey: "lst")
    UserDefaults.standard.setColor(light_background, forKey: "lb")
    UserDefaults.standard.setColor(light_selection, forKey: "ls")
    UserDefaults.standard.setColor(light_current, forKey: "lcl")
    UserDefaults.standard.setColor(light_cursor, forKey: "lc")
    
    UserDefaults.standard.setColor(dark_standard, forKey: "dst")
    UserDefaults.standard.setColor(dark_background, forKey: "db")
    UserDefaults.standard.setColor(dark_selection, forKey: "ds")
    UserDefaults.standard.setColor(dark_current, forKey: "dcl")
    UserDefaults.standard.setColor(dark_cursor, forKey: "dc")
}

func setTheme(_ theme: Int) -> Void {
    switch theme {
        case 0: // Default
            light_color1 = neoRGB(155, 35, 147)
            light_color2 = neoRGB(28, 70, 74)
            light_color4 = neoRGB(28, 0, 207)
            light_color5 = neoRGB(93, 108, 121)
            light_color6 = neoRGB(196, 26, 22)
            light_color7 = neoRGB(57, 0, 160)
            light_color8 = neoRGB(15, 104, 160)
            light_color10 = neoRGB(100, 56, 32)
        
            dark_color1 = neoRGB(252, 95, 163)
            dark_color2 = neoRGB(93, 216, 255)
            dark_color4 = neoRGB(208, 191, 105)
            dark_color5 = neoRGB(108, 121, 134)
            dark_color6 = neoRGB(252, 106, 93)
            dark_color7 = neoRGB(208, 168, 255)
            dark_color8 = neoRGB(65, 161, 192)
            dark_color10 = neoRGB(253, 143, 63)
        
            light_standard = UIColor.black
            light_background = neoRGB(255, 255, 255)
            light_selection = neoRGB(164, 205, 255)
            light_current = neoRGB(232, 242, 255)
            light_cursor = neoRGB(0, 0, 0)
        
            dark_standard = UIColor.white
            dark_background = neoRGB(31, 31, 36)
            dark_selection = neoRGB(81, 91, 112)
            dark_current = neoRGB(35, 37, 43)
            dark_cursor = neoRGB(255, 255, 255)
        case 1: // Dusk
            light_color1 = neoRGB(178, 24, 137)
            light_color2 = neoRGB(93, 216, 255)
            light_color4 = neoRGB(120, 109, 196)
            light_color5 = neoRGB(65, 182, 69)
            light_color6 = neoRGB(219, 44, 56)
            light_color7 = neoRGB(0, 160, 190)
            light_color8 = neoRGB(65, 161, 192)
            light_color10 = neoRGB(198, 124, 72)
    
            dark_color1 = light_color1
            dark_color2 = light_color2
            dark_color4 = light_color4
            dark_color5 = light_color5
            dark_color6 = light_color6
            dark_color7 = light_color7
            dark_color8 = light_color8
            dark_color10 = light_color10
    
            light_standard = UIColor.white
            light_background = neoRGB(30, 32, 40)
            light_selection = neoRGB(84, 85, 74)
            light_current = neoRGB(45, 45, 45)
            light_cursor = neoRGB(255, 255, 255)
    
            dark_standard = light_standard
            dark_background = light_background
            dark_selection = light_selection
            dark_current = light_current
            dark_cursor = light_cursor
        case 2: //Midnight
            light_color1 = neoRGB(211, 24, 149)
            light_color2 = neoRGB(93, 216, 255)
            light_color4 = neoRGB(120, 109, 255)
            light_color5 = neoRGB(65, 204, 69)
            light_color6 = neoRGB(255, 44, 56)
            light_color7 = neoRGB(0, 160, 255)
            light_color8 = neoRGB(65, 161, 192)
            light_color10 = neoRGB(228, 124, 72)

            dark_color1 = light_color1
            dark_color2 = light_color2
            dark_color4 = light_color4
            dark_color5 = light_color5
            dark_color6 = light_color6
            dark_color7 = light_color7
            dark_color8 = light_color8
            dark_color10 = light_color10

            light_standard = UIColor.white
            light_background = neoRGB(0, 0, 0)
            light_selection = neoRGB(75, 71, 64)
            light_current = neoRGB(26, 25, 25)
            light_cursor = neoRGB(255, 255, 255)

            dark_standard = light_standard
            dark_background = light_background
            dark_selection = light_selection
            dark_current = light_current
            dark_cursor = light_cursor
        default:
            return
    }
}
// MARK: NeoColorMGMT

extension UserDefaults {
    func setColor(_ color: UIColor, forKey key: String) {
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
            self.set(colorData, forKey: key)
        }
    }
    
    func color(forKey key: String) -> UIColor {
        if let colorData = self.data(forKey: key),
           let color = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
            return color
        }
        return UIColor.clear
    }
}

// MARK: settings
struct NeoEditorSettings: View {
    @AppStorage("CERender") var render: Double = 1.0
    @AppStorage("CEFontSize") var font: Double = 13.0
    @AppStorage("CEToolbar") var toolbar: Bool = true
    @AppStorage("CECurrentLineHighlighting") var current_line_highlighting: Bool = true
    var body: some View {
        List {
            Section(header: Text("Themes")) {
                Button("Default") {
                    setTheme(0)
                    storeTheme()
                }
                Button("Dusk") {
                    setTheme(1)
                    storeTheme()
                }
                Button("Midnight") {
                    setTheme(2)
                    storeTheme()
                }
            }
            Section(header: Text("Advanced Graphic Settings")) {
                HStack {
                    Text("Render: \(NumberFormatter.localizedString(from: NSNumber(value: render), number: .percent))")
                        .frame(width: 150)
                    Slider(value: $render, in: 0...1)
                }
                Stepper("Font Size: \(String(Int(font)))", value: $font, in: 0...20)
                Toggle("Toolbar", isOn: $toolbar)
                Toggle("Current Line Highlighting", isOn: $current_line_highlighting)
            }
        }
        .navigationTitle("Code Editor")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(InsetGroupedListStyle())
    }
}
