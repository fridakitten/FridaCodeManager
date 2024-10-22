 /* 
 UIRuleCase.swift 

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
import Foundation
import UIKit

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
