 /*
 UIConsole.swift

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

let LogPipe = Pipe()

struct NeoLog: View {
    @State var LogItems: [LogItem] = []
    @State var width: CGFloat
    @State var height: CGFloat

    var body: some View {
        ScrollView {
            ScrollViewReader { scroll in
                VStack(alignment: .leading) {
                    ForEach(LogItems) { item in
                        let cleanedMessage = item.Message
                            .split(separator: "\n")
                            .filter { !$0.contains("perform implicit import of") }
                            .joined(separator: "\n")

                        if !cleanedMessage.isEmpty {
                            Text(highlightMessage(cleanedMessage))
                                .font(.system(size: 9, weight: .regular, design: .monospaced))
                                .foregroundColor(.primary)
                                .id(item.id)
                        }
                    }
                }
                .onChange(of: LogItems) { _ in
                    DispatchQueue.main.async {
                        withAnimation {
                            scroll.scrollTo(LogItems.last?.id, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(width: width, height: height)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .contextMenu {
            Button(action: {
                var textToCopy: String = ""
                for logItem in LogItems {
                    textToCopy += "\(logItem.Message)\n"
                }
                let cleanTextToCopy = textToCopy
                    .split(separator: "\n")
                    .filter { !$0.contains("perform implicit import of") }
                    .joined(separator: "\n")
                copyToClipboard(text: cleanTextToCopy)
            }) {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
        .onAppear {
            LogPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                let logData = fileHandle.availableData
                if !logData.isEmpty, let logString = String(data: logData, encoding: .utf8) {
                    LogItems.append(LogItem(Message: logString))
                }
            }

            setvbuf(stdout, nil, _IOLBF, 0)
            setvbuf(stderr, nil, _IOLBF, 0)

            dup2(LogPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
            dup2(LogPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        }
    }

    private func highlightMessage(_ message: String) -> AttributedString {
        var attributedString = AttributedString()

        let patterns: [(String, Color)] = [
            ("(?i)warning(?=\\s*:)", .orange),
            ("(?i)error(?=\\s*:)", .red),
            ("(?i)note(?=\\s*:)", .blue)
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

            let matchText = String(message[range])
            var highlightedText = AttributedString(matchText)
            highlightedText.foregroundColor = match.color
            highlightedText.font = .system(size: 9, weight: .bold, design: .monospaced)
            attributedString.append(highlightedText)

            currentIndex = range.upperBound
        }

        if currentIndex < message.endIndex {
            let remainingText = String(message[currentIndex...])
            attributedString.append(AttributedString(remainingText))
        }

        return attributedString
    }
}

struct LogItem: Identifiable, Equatable {
    var id = UUID()
    var Message: String
}

extension String {
    func lineFix() -> String {
        return String(self.last == "\n" ? String(self.dropLast()) : self)
    }
}

func copyToClipboard(text: String, alert: Bool? = true) {
    haptfeedback(1)
    if (alert ?? true) {ShowAlert(UIAlertController(title: "Copied", message: "", preferredStyle: .alert))}
    UIPasteboard.general.string = text
    if (alert ?? true) {DismissAlert()}
}
