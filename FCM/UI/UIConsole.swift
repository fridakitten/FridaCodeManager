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
    @State var LogItems: [String.SubSequence] = ["!waiting on execution!"] 
    @Binding var show: Bool
    @AppStorage("cmp") var cmp: Bool = true
    var body: some View {
        Group {
            if show == true {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            Text("\(LogItems.filter { !$0.contains("remark:") && !$0.contains("note:") }.joined(separator: "\n"))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .flipped()
                    }
                    .padding(.horizontal)
                    .flipped()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15)
                }
                .frame(width: UIScreen.main.bounds.width / 1.2,height: UIScreen.main.bounds.height / 2)
            } else if cmp == true {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(UIColor.systemGray6))
                        .frame(width: UIScreen.main.bounds.width / 1.2,height: 50)
                        .cornerRadius(15)
                        .onDisappear {
                            cmp = false
                        }
                    Text("Warning: on first compile it gonna take a few minutes")
                        .font(.system(size: 11,weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .contextMenu {
            Button("Copy Log") {
                var fullstring: String = ""
                for item in LogItems {
                    fullstring += "\(item)\n"
                }
                copyToClipboard(text: fullstring, alert: false)
            }
        }
        .onDisappear {
            LogItems = ["!waiting on execution!"]
        }
        Spacer().frame(height: 0)
        .onAppear {
            LogStream($LogItems)
        }
    }
}
func copyToClipboard(text: String, alert: Bool? = true) {
    haptfeedback(1)
    if (alert ?? true) {ShowAlert(UIAlertController(title: "Copied", message: "", preferredStyle: .alert))}
    UIPasteboard.general.string = text
    if (alert ?? true) {DismissAlert()}
}

//From https://github.com/Odyssey-Team/Taurine/blob/main/Taurine/app/LogStream.swift
//Code from Taurine https://github.com/Odyssey-Team/Taurine under BSD 4 License
class LogStream {
    private(set) var outputString = ""
    private(set) var outputFd: [Int32] = [0, 0]
    private(set) var errFd: [Int32] = [0, 0]
    private let readQueue: DispatchQueue
    private let outputSource: DispatchSourceRead
    private let errorSource: DispatchSourceRead
    init(_ LogItems: Binding<[String.SubSequence]>) {
        readQueue = DispatchQueue(label: "org.coolstar.sileo.logstream", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
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
        }
        errorSource.setCancelHandler {
            close(self.errFd[0])
            close(self.errFd[1])
        }
        let bufsiz = Int(BUFSIZ)
        outputSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(self.outputFd[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1 && errno == EAGAIN {
                    return
                }
                self.outputSource.cancel()
                return
            }
            write(origOutput, buffer, bytesRead)
            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                self.outputString.append(str)
                LogItems.wrappedValue = self.outputString.split(separator: "\n")
            }
        }
        errorSource.setEventHandler {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufsiz)
            defer { buffer.deallocate() }
            let bytesRead = read(self.errFd[0], buffer, bufsiz)
            guard bytesRead > 0 else {
                if bytesRead == -1 && errno == EAGAIN {
                    return
                }
                self.errorSource.cancel()
                return
            }
            write(origErr, buffer, bytesRead)
            let array = Array(UnsafeBufferPointer(start: buffer, count: bytesRead)) + [UInt8(0)]
            array.withUnsafeBufferPointer { ptr in
                let str = String(cString: unsafeBitCast(ptr.baseAddress, to: UnsafePointer<CChar>.self))
                self.outputString.append(str)
                LogItems.wrappedValue = self.outputString.split(separator: "\n")
            }
        }
        outputSource.resume()
        errorSource.resume()
    }
}
