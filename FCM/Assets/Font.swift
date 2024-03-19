import UIKit

func guif() -> [String] {
    var fontFamilies = UIFont.familyNames
    fontFamilies.sort { (family1, family2) in
        if family1.lowercased() == "menlo" {
            return true
        } else if family2.lowercased() == "menlo" {
            return false
        }
        return family1.lowercased() < family2.lowercased()
    }
    return fontFamilies
}
func gsuffix(from fileName: String) -> String {
    let trimmedFileName = fileName.replacingOccurrences(of: " ", with: "")
    let suffix = URL(string: trimmedFileName)?.pathExtension
    return suffix ?? ""
}