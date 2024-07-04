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

// Just use the same FD every time
let LogPipe = Pipe()

struct NeoLog: View {
    @State var LogItems: [LogItem] = []
    var body: some View {
        ScrollView {
            ScrollViewReader { scroll in
                VStack(alignment: .leading) {
                    ForEach(LogItems) { Item in
                        if !Item.Message.contains("perform implicit import of") {
                            Text("\(Item.Message.lineFix())")
                                .font(.system(size: 9, weight: .regular, design: .monospaced))
                                .foregroundColor(.primary)
                                .id(Item.id)
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
        .frame(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.height / 2.5)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .onAppear {
            LogPipe.fileHandleForReading.readabilityHandler = { fileHandle in
                if let logString = String(data: fileHandle.availableData, encoding: .utf8) {
                    LogItems.append(LogItem(Message: logString))
                }
            }
            setvbuf(stdout, nil, _IONBF, 0)
            setvbuf(stderr, nil, _IONBF, 0)
            dup2(LogPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
            dup2(LogPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
        }
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
