import Foundation
import UIKit

struct ext: Identifiable {
    let id: UUID = UUID()
    let before: String
    let flag: String
    let after: String
}

func tags(_ inputString: String,_ tag: String) -> String {
    do {
        let regex = try NSRegularExpression(pattern: "<\(tag)>(.*?)</\(tag)>", options: .dotMatchesLineSeparators)
        if let match = regex.firstMatch(in: inputString, options: [], range: NSRange(location: 0, length: inputString.utf16.count)) {
            if let range = Range(match.range(at: 1), in: inputString) {
                return String(inputString[range])
            }
        }
    } catch {
        print("Error creating regular expression: \(error.localizedDescription)")
    }
    
    return ""
}