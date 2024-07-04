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
import Foundation

struct LogView: View {
    @State var LogItems: [String.SubSequence] = [""] 
    @Binding var show: Bool
    @State var fullLog: String {
        LogItems.filter {
            !$0.contains("perform implicit import") && !$0.contains("clang-14: warning: -framework")
        }.joined(separator: "\n")
    }

    var body: some View {
        Group {
            if show == true {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(fullLog)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        //.flipped()
                    }
                    .padding(.horizontal)
                    //.flipped()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15)
                }
                .frame(width: UIScreen.main.bounds.width / 1.2,height: UIScreen.main.bounds.height / 2)
            }
        }
        .contextMenu {
            Button("Copy Log") {
                copyToClipboard(text: fullLog, alert: true) // better let the user know if the copy goes fine
            }
        }
        .onDisappear {
            LogItems = ["!waiting on execution!"]
        }
        Spacer().frame(height: 0)
        .onAppear {
            _ = LogStream($LogItems)
        }
    }
}
func copyToClipboard(text: String, alert: Bool? = true) {
    // TODO: May I, lebao3105, use toast message (that pops down from top of the screen)
    // which is used in Swifile before? Instead of an alert. Named SimpleToast, it looks good!
    haptfeedback(1)
    if (alert ?? true) {ShowAlert(UIAlertController(title: "Copied", message: "", preferredStyle: .alert))}
    UIPasteboard.general.string = text
    if (alert ?? true) {DismissAlert()}
}

class LogStream {
    private(set) var outputString = ""
    private(set) var outputFd: [Int32] = [0, 0]
    private(set) var errFd: [Int32] = [0, 0]
    private let readQueue: DispatchQueue
    private let outputSource: DispatchSourceRead
    private let errorSource: DispatchSourceRead
    
    init(_ LogItems: Binding<[String.SubSequence]>) {
        readQueue = DispatchQueue(label: "com.sparklechan.swifty", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        
        pipe(&outputFd)
        pipe(&errFd)
        
        let origOutput = dup(STDOUT_FILENO)
        let origErr = dup(STDERR_FILENO)
        
        setvbuf(stdout, nil, _IONBF, 0)
        dup2(outputFd[1], STDOUT_FILENO)
        dup2(errFd[1], STDERR_FILENO)
        
        outputSource = DispatchSource.makeReadSource(fileDescriptor: outputFd[0], queue: readQueue)
        errorSource = DispatchSource.makeReadSource(fileDescriptor: errFd[0], queue: readQueue)
        
        outputSource.setCancelHandler {
            close(self.outputFd[0])
            close(self.outputFd[1])
            dup2(origOutput, STDOUT_FILENO)
            close(origOutput)
        }
        
        errorSource.setCancelHandler {
            close(self.errFd[0])
            close(self.errFd[1])
            dup2(origErr, STDERR_FILENO)
            close(origErr)
        }
        
        let bufsiz = Int(BUFSIZ)
        
        outputSource.setEventHandler { [weak self] in
            self?.handleOutputEvent(bufferSize: bufsiz, originalFd: origOutput, logItems: LogItems)
        }
        
        errorSource.setEventHandler { [weak self] in
            self?.handleErrorEvent(bufferSize: bufsiz, originalFd: origErr, logItems: LogItems)
        }
        
        outputSource.resume()
        errorSource.resume()
    }
    
    private func handleOutputEvent(bufferSize: Int, originalFd: Int32, logItems: Binding<[String.SubSequence]>) {
        handleEvent(fileDescriptor: outputFd[0], bufferSize: bufferSize, originalFd: originalFd, logItems: logItems)
    }
    
    private func handleErrorEvent(bufferSize: Int, originalFd: Int32, logItems: Binding<[String.SubSequence]>) {
        handleEvent(fileDescriptor: errFd[0], bufferSize: bufferSize, originalFd: originalFd, logItems: logItems)
    }
    
    private func handleEvent(fileDescriptor: Int32, bufferSize: Int, originalFd: Int32, logItems: Binding<[String.SubSequence]>) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        let bytesRead = read(fileDescriptor, buffer, bufferSize)
        guard bytesRead > 0 else {
            if bytesRead == -1 && errno == EAGAIN {
                return
            }
            if fileDescriptor == outputFd[0] {
                outputSource.cancel()
            } else {
                errorSource.cancel()
            }
            return
        }
        
        write(originalFd, buffer, bytesRead)
        
        let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
        array.withUnsafeBufferPointer { ptr in
            let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
            self.outputString.append(str)
            logItems.wrappedValue = self.outputString.split(separator: "\n")
        }
    }
}