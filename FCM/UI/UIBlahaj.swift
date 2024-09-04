//
// UIBlahaj.swift
//
// Created by SeanIsNotAConstant on 04.09.24
//
 
import UIKit

// Function to paste text from clipboard into the currently focused text input
func pasteFromClipboard() {
    // Get the shared pasteboard
    let pasteboard = UIPasteboard.general
    
    // Check if the pasteboard contains string data
    guard let clipboardText = pasteboard.string else {
        print("Clipboard does not contain any text.")
        return
    }
    
    // Access the currently focused text input
    if let focusedTextInput = UIResponder.currentFirstResponder as? UITextInput {
        // Create a text range to insert the clipboard text
        let textRange = focusedTextInput.selectedTextRange
        focusedTextInput.replace(textRange!, withText: clipboardText)
    } else {
        print("No text input is currently focused.")
    }
}

// Extension to get the current first responder
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

func setClipboardText(_ text: String) {
    // Get the shared pasteboard
    let pasteboard = UIPasteboard.general
    
    // Set the string to the clipboard
    pasteboard.string = text
    
    print("Text set to clipboard: \(text)")
}