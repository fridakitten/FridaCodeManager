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

import SwiftUI
import UIKit
import Foundation

public struct HighlightedTextEditor: UIViewRepresentable, HighlightingTextEditor {

    public struct Internals {
        public let textView: SystemTextView
        public let scrollView: SystemScrollView?
    }

    @Binding var text: String

    let highlightRules: [HighlightRule]
    let lineNumberLabel = UILabel()

    private(set) var onEditingChanged: OnEditingChangedCallback?
    private(set) var onCommit: OnCommitCallback?
    private(set) var onTextChange: OnTextChangeCallback?
    private(set) var onSelectionChange: OnSelectionChangeCallback?
    private(set) var introspect: IntrospectCallback?

    public init(
        text: Binding<String>,
        highlightRules: [HighlightRule]
    ) {
        _text = text
        self.highlightRules = highlightRules
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        //updateTextViewModifiers(textView)
        runIntrospect(textView)

        setupToolbar(textView: textView)

        return textView
    }

    func setupToolbar(textView: UITextView) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // Create the "Tab" button
        let tabButton = ClosureBarButtonItem(title: "Tab", style: .plain) {
            self.buttonTapped()
        }
        
        // Create flexible space
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Create the line number label
        lineNumberLabel.text = "Line n/a"
        lineNumberLabel.sizeToFit()
        lineNumberLabel.lineBreakMode = .byWordWrapping
        lineNumberLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 40
        var newFrame = lineNumberLabel.frame
        newFrame.size.width = 100
        lineNumberLabel.frame = newFrame
        lineNumberLabel.textAlignment = .right
        
        let lineNumberItem = UIBarButtonItem(customView: lineNumberLabel)
        toolbar.items = [tabButton, flexibleSpace, lineNumberItem]
        
        textView.inputAccessoryView = toolbar
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = .zero
    }

    public func buttonTapped() {
        setClipboardText("\t")
        pasteFromClipboard()
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        guard !context.coordinator.updatingUIView else { return }

        let highlightedText = HighlightedTextEditor.getHighlightedText(
            text: text,
            highlightRules: highlightRules
        )

        if let range = uiView.markedTextNSRange {
            uiView.setAttributedMarkedText(highlightedText, selectedRange: range)
        } else {
            if uiView.attributedText != highlightedText {
                uiView.attributedText = highlightedText
            }
        }

        runIntrospect(uiView)
        uiView.selectedTextRange = context.coordinator.selectedTextRange
    }

    private func runIntrospect(_ textView: UITextView) {
        guard let introspect = introspect else { return }
        let internals = Internals(textView: textView, scrollView: nil)
        introspect(internals)
    }

    public final class Coordinator: NSObject, UITextViewDelegate {
        var parent: HighlightedTextEditor
        var selectedTextRange: UITextRange?
        var updatingUIView = false

        init(_ markdownEditorView: HighlightedTextEditor) {
            self.parent = markdownEditorView
        }

        public func textViewDidChange(_ textView: UITextView) {

            guard textView.markedTextRange == nil else { return }
            
            parent.text = textView.text
            selectedTextRange = textView.selectedTextRange
        }

        public func textViewDidChangeSelection(_ textView: UITextView) {
            guard let onSelectionChange = parent.onSelectionChange, !updatingUIView else { gimmetheline(textView) ; return }

            selectedTextRange = textView.selectedTextRange
            onSelectionChange([textView.selectedRange])
        }

        public func gimmetheline(_ textView: UITextView) {
            guard let selectedTextRange = textView.selectedTextRange else {
                parent.lineNumberLabel.text = "Error"
                return
            }

            let characterIndex = textView.offset(from: textView.beginningOfDocument, to: selectedTextRange.start)

            DispatchQueue.global(qos: .userInitiated).async {
                let textBeforeCaret = textView.text.prefix(characterIndex)

                let logicalLineNumber = textBeforeCaret.filter { $0.isNewline }.count + 1

                DispatchQueue.main.async {
                    self.parent.lineNumberLabel.text = "Line \(logicalLineNumber)"
                }
            }
        }
    }
}

public extension HighlightedTextEditor {
    func introspect(callback: @escaping IntrospectCallback) -> Self {
        var new = self
        new.introspect = callback
        return new
    }

    func onTextChange(_ callback: @escaping OnTextChangeCallback) -> Self {
        var new = self
        new.onTextChange = callback
        return new
    }
}