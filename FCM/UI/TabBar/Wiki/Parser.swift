import SwiftUI
import Foundation

struct Hierarchy: Identifiable {
    let id = UUID()
  
    var sections: [WikiSection]
    var texts: [TextItem]
}

struct WikiSection: Identifiable {
    let id = UUID()
    var name: String
    var items: [TextOrNavItem]
}

enum TextOrNavItem: Identifiable {
    case text(TextItem)
    case navLink(NavLinkItem)
    case breakSpace(BreakItem)
    
    var id: UUID {
        switch self {
        case .text(let text): return text.id
        case .navLink(let navLink): return navLink.id
        case .breakSpace(let breakSpace): return breakSpace.id
        }
    }
}

struct TextItem: Identifiable {
    let id = UUID()
    var content: String
    var type: Int
}

struct NavLinkItem: Identifiable {
    let id = UUID()
    var filePath: String
    var title: String
}

struct BreakItem: Identifiable {
    let id = UUID()
    var spacing: CGFloat
}

class XMLParserHandler: NSObject, XMLParserDelegate {
    private var currentSection: WikiSection?
    private var currentText: TextItem?
    private var hierarchy = Hierarchy(sections: [], texts: [])
    
    var result: Hierarchy {
        return hierarchy
    }
    
    // Called when the parser starts reading an element
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "section":
            if let name = attributeDict["name"] {
                currentSection = WikiSection(name: name, items: [])
            }
        case "text":
            if let content = attributeDict["content"] {
                if let type = attributeDict["type"] {
                    if let type: Int = Int(type) {
                        currentText = TextItem(content: replaceMarks(in: replaceLiteralNewlines(in: content)), type: type)
                    }
                }
            }
        case "break":
            if let spacingString = attributeDict["spacing"], let spacingValue = Int(spacingString) {
                let breakItem = BreakItem(spacing: CGFloat(spacingValue))
                if var currentSection = currentSection {
                    currentSection.items.append(.breakSpace(breakItem))
                    self.currentSection = currentSection
                }
            }
        case "navlink":
            if let filePath = attributeDict["file"] {
                if var currentSection = currentSection {
                    if let title = attributeDict["title"] {
                        currentSection.items.append(.navLink(NavLinkItem(filePath: filePath, title: title)))
                        self.currentSection = currentSection
                    }
                } else {
                    if let title = attributeDict["title"] {
                        hierarchy.texts.append(TextItem(content: title, type: 0))
                    }
                }
            }
        default:
            break
        }
    }
    
    // Called when the parser ends reading an element
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "section":
            if let section = currentSection {
                hierarchy.sections.append(section)
                currentSection = nil
            }
        case "text":
            if let text = currentText {
                if var currentSection = currentSection {
                    currentSection.items.append(.text(text))
                    self.currentSection = currentSection // Update modified section
                } else {
                    hierarchy.texts.append(text)
                }
                currentText = nil
            }
        default:
            break
        }
    }
}

func parseXML(data: Data) -> Hierarchy? {
    let parser = XMLParser(data: data)
    let handler = XMLParserHandler()
    parser.delegate = handler
    if parser.parse() {
        return handler.result
    }
    return nil
}

struct TextLabel: View {
    var text: TextItem
    
    var body: some View {
        switch text.type {
        case 0:
            Text(highlightMessage(text.content))
        case 1:
            Text(text.content)
                .font(.system(size: 14, weight: .regular, design: .monospaced))
                .foregroundColor(Color.primary)
                .background(Color(UIColor.systemGray5))
                .cornerRadius(4)
        default:
            Spacer().frame(width: 0, height: 0)
        }
    }
}

private func highlightMessage(_ message: String) -> AttributedString {
    var attributedString = AttributedString()

    let patterns: [(String, Color)] = [
        (#"\*\*(.*?)\*\*|\*(.*?)\*"#, .primary)
    ]

    var currentIndex = message.startIndex
    var matches: [(range: NSRange, color: Color)] = []

    for pattern in patterns {
        guard let regex = try? NSRegularExpression(pattern: pattern.0) else { continue }
        let patternMatches = regex.matches(in: message, options: [], range: NSRange(location: 0, length: message.utf16.count))
        for match in patternMatches {
            matches.append((match.range, pattern.1))
        }
    }

    matches.sort { $0.range.location < $1.range.location }

    for match in matches {
        let range = Range(match.range, in: message)!

        if currentIndex < range.lowerBound {
            let preText = String(message[currentIndex..<range.lowerBound])
            attributedString.append(AttributedString(preText))
        }

        // Extract only the content between ** or * symbols
        let matchText = String(message[range])
        let strippedText: String
        if matchText.hasPrefix("**") && matchText.hasSuffix("**") {
            strippedText = String(matchText.dropFirst(2).dropLast(2)) // Remove **
        } else if matchText.hasPrefix("*") && matchText.hasSuffix("*") {
            strippedText = String(matchText.dropFirst(1).dropLast(1)) // Remove *
        } else {
            strippedText = matchText // No special characters, use as is
        }

        var highlightedText = AttributedString(strippedText)
        highlightedText.foregroundColor = match.color
        highlightedText.font = .system(size: 17, weight: .bold)
        attributedString.append(highlightedText)

        currentIndex = range.upperBound
    }

    if currentIndex < message.endIndex {
        let remainingText = String(message[currentIndex...])
        attributedString.append(AttributedString(remainingText))
    }

    return attributedString
}

func replaceLiteralNewlines(in input: String) -> String {
    return input.replacingOccurrences(of: #"\n"#, with: "\n")
}

func replaceMarks(in input: String) -> String {
    return input.replacingOccurrences(of: "'", with: "\"")
}