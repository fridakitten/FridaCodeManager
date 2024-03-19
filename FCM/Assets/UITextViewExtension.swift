#if os(iOS)
import Foundation
import UIKit

extension UITextView {
    var markedTextNSRange: NSRange? {
        markedTextRange.map { NSRange(location: offset(from: beginningOfDocument, to: $0.start), length: offset(from: $0.start, to: $0.end)) }
    }
}

#endif