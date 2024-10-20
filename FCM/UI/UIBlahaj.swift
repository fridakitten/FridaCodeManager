//
// UIBlahaj.swift
//
// Created by SeanIsNotAConstant on 04.09.24
//
 
import UIKit

public func pasteFromClipboard() -> Void {
    let pasteboard = UIPasteboard.general
    
    guard let clipboardText = pasteboard.string else {
        print("Clipboard does not contain any text.")
        return
    }
    
    if let focusedTextInput = UIResponder.currentFirstResponder as? UITextInput {
        let textRange = focusedTextInput.selectedTextRange
        focusedTextInput.replace(textRange!, withText: clipboardText)
    } else {
        print("No text input is currently focused.")
    }
}

public func setClipboardText(_ text: String) {
    let pasteboard = UIPasteboard.general
    
    pasteboard.string = text
    
    print("Text set to clipboard: \(text)")
}

extension UIResponder {
    private weak static var _currentFirstResponder: UIResponder?

    static var currentFirstResponder: UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return _currentFirstResponder
    }

    @objc private func findFirstResponder(_ sender: Any?) {
        UIResponder._currentFirstResponder = self
    }
}
