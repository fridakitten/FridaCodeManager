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

private func getlevelback(_ level: Int) -> Color {
    switch level {
        case -1:
            return Color(UIColor.systemGreen.withAlphaComponent(0.2))
        case 0:
            return Color(UIColor.systemBlue.withAlphaComponent(0.2))
        case 1:
            return Color(UIColor.systemYellow.withAlphaComponent(0.2))
        case 2:
            return Color(UIColor.systemRed.withAlphaComponent(0.2))
        default:
            return Color(UIColor.clear)
    }
}

struct NeoLog: View {
   @Binding var LogItems: [LogItem]
   @Binding var LogCache: [LogItem]
   @Binding var buildv: Bool
   @Binding var LogViews: [logstruct]
   @State var type: Int = 0
   let action: () -> Void

   init(
       buildv: Binding<Bool>,
       LogItems: Binding<[LogItem]>,
       LogCache: Binding<[LogItem]>,
       LogViews: Binding<[logstruct]>,
       action: @escaping () -> Void
   ) {
       UIInit(type: 1)
       _buildv = buildv
       errorcache = []
       _LogItems = LogItems
       _LogViews = LogViews
       _LogCache = LogCache
       self.action = action
   }

   var body: some View {
       NavigationView {
            Group {
                if type == 0 {
                    List {
                        ForEach(LogViews) { item in
                            LevelItem(logstruct: item)
                                .listRowBackground(getlevelback(item.level))
                        }
                    }
                } else {
                    ScrollView {
                        Spacer().frame(height: 10)
                        ForEach(LogCache) { item in
                            HStack {
                                Text(highlightMessage(item.Message.lineFix()))
                                    .font(.system(size: 10, design: .monospaced))
                                Spacer()
                            }
                        }
                    }
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

                action()
            }
            .onChange(of: LogItems) { _ in
                LogCache += LogItems
                let tmpcache = getlog(logitems: LogItems)
                LogItems = []
                withAnimation {
                    LogViews += tmpcache
                }
            }
            .navigationTitle("Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Issue Navigator") {
                            type = 0
                        }
                        Button("Log") {
                            type = 1
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        UIInit(type: 0)
                        buildv = false
                        errorcache = LogViews
                        killallchilds()
                    }
                    .foregroundColor(.primary)
                }
            }
       }
       .navigationViewStyle(.stack)
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

// MARK: LOG
func getlog(logitems: [LogItem]) -> [logstruct] {
    var logstructs: [logstruct] = []
    
    for item in logitems {
        let substrings: [String] = extractLines(from: item.Message)

        for substring in substrings {
            let subitems: [String] = splitStringByColon(input: substring)
            
            if subitems.count > 4 && subitems[4] != " no such module found" && FileManager.default.fileExists(atPath: subitems[0])  {
                let finalitem: logstruct = logstruct(file: subitems[0], line: Int(subitems[1]) ?? -1, level: getlevel(subitems[3]), description: subitems[4], detail: extractLine(from: subitems[0], lineNumber: Int(subitems[1]) ?? -1) ?? "Error: File couldnt be opened")
                logstructs.append(finalitem)
            }
        }
    }
    
    return logstructs
}

func extractLine(from filePath: String, lineNumber: Int) -> String? {
    guard FileManager.default.fileExists(atPath: filePath) else {
        print("File does not exist: \(filePath)")
        return nil
    }

    do {
        let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
        let lines = fileContents.components(separatedBy: .newlines)
        
        // Ensure line number is valid
        if lineNumber > 0 && lineNumber <= lines.count {
            return lines[lineNumber - 1].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            print("Line number \(lineNumber) is out of range.")
            return nil
        }
    } catch {
        print("An error occurred: \(error)")
        return nil
    }
}

func getlevel(_ messageParty: String) -> Int {
    switch messageParty {
    case " succeed":
        return -1
    case " note":
        return 0
    case " warning":
        return 1
    case " error":
        return 2
    default:
        return 0
    }
}

// MARK: XCode error list stuff
struct logstruct: Identifiable {
    let id: UUID = UUID()
    let file: String
    let line: Int
    let level: Int
    let description: String
    let detail: String
}

struct LevelItem: View {
    @State var logstruct: logstruct
    var body: some View {
        VStack {
            HStack {
                switch logstruct.level {
                case 2:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.red)
                case 1:
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color.yellow)
                case 0:
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color.blue)
                case -1:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                default:
                    Spacer().frame(width: 0, height: 0)
                }
                Text(logstruct.description)
                    .font(.system(size: 10.0))
                Spacer()
            }
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary)
            HStack {
                Text("\(logstruct.detail)")
                    .font(.system(size: 10.0))
                Spacer()
            }
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.secondary)
            if logstruct.file != " " {
                HStack {
                    Text("file: \(logstruct.file)")
                        .font(.system(size: 10.0))
                    Spacer()
                }
                HStack {
                    Text("line: \(logstruct.line)")
                        .font(.system(size: 10.0))
                    Spacer()
                }
            }
        }
    }
}

func splitStringByColon(input: String) -> [String] {
    return input.components(separatedBy: ":")
}

func extractFirstLine(from input: String) -> String {
    let lines = input.components(separatedBy: .newlines)
    
    if let first = lines.first {
        return first
    }
    
    return input
}

func extractLines(from input: String) -> [String] {
    return input.components(separatedBy: .newlines)
}
