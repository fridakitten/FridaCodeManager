import SwiftUI
import Foundation
import UIKit

func grule(_ isaythis: String) -> [HighlightRule] {
    if isaythis == "swift" {
        return [
         HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\.)\\w+(?=[(])", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(let|var|struct|some|import|private|class|nil|return|func|override)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor (red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<=\\b(let|var|struct|func|class)\\s)\\w+", options: []), formattingRules: [
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
    } else if ["c", "m", "cpp", "mm"].contains(isaythis) {
        return [
         HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(struct|#import|#include|nil|return)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor (red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "@\\w+[^()]", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.7137, green: 0, blue: 1, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b\\w+\\s*(?=\\{)", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(int|float|double|BOOL|char|NSString|CGFloat|CGRect|CGPoint|\\w+_t)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.7137, green: 0, blue: 1, alpha: 1.0)) 
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "\\b(-?\\d+(\\.\\d+)?|true|false)\\b", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0.7569, green: 0.2039, blue: 0.3882, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(//.*|\\/\\*[\\s\\S]*?\\*\\/)", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 0, green: 0.4824, blue: 0.9098, alpha: 1.0))
        ]), HighlightRule(pattern: try! NSRegularExpression(pattern: "(?<!\\/\\/)(\"(.*?)\")", options: []), formattingRules: [
            TextFormattingRule(key: .foregroundColor, value: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        ])
    ]
    }
    return []
}