//
//  LogSystem.swift
//  FloatingDebugLog
//
//  Created by fridakitten on 14.11.24.
//

// LogSystem for FridaCodeManager
// so its a bit easier :3

import SwiftUI
import Foundation

// log system
let mainlogSystem: LogSystem = LogSystem()

class LogSystem: ObservableObject {
    private let loggingPipe = Pipe()
    @Published private(set) var log: [LogItem] = []
    
    private let logQueue = DispatchQueue(label: "LogSystem.logQueue")
    
    init() {
        loggingPipe.fileHandleForReading.readabilityHandler = { [weak self] fileHandle in
            guard let self = self else { return }
            let logData = fileHandle.availableData
            if !logData.isEmpty, let logString = String(data: logData, encoding: .utf8) {
                self.addLog(logString)
            }
        }

        setvbuf(stdout, nil, _IOLBF, 0)
        setvbuf(stderr, nil, _IOLBF, 0)
        
        dup2(loggingPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(loggingPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }
    
    private func addLog(_ unfiltered_item: String) {
        var items = unfiltered_item.split(separator: "\n")
        var item: String = ""
        for line in items {
            if !line.contains("remark:") {
                item.append("\(line)\n")
            }
        }
        DispatchQueue.main.async {
            self.log.append(LogItem(Message: item))
            if self.log.count > 100 {
                self.log.removeFirst(self.log.count - 100)
            }
        }
    }
    
    func dumpLog() {
        let items = self.log
    
        logQueue.async {
            let path: String = "\(NSTemporaryDirectory())\(UUID())-logdump.txt"
            let logContent = {
                var content: String = ""
                for item in items {
                    content += item.Message
                }

                return content
            }()

            DispatchQueue.main.sync {
                do {
                    try logContent.write(toFile: path, atomically: true, encoding: .utf8)
                } catch {
                    print("Failed to write log to \(path): \(error)")
                }
                let fileURL: URL = URL(fileURLWithPath: path)
                print(fileURL.path)
                share(url: fileURL, remove: true)
            }
        }
    }
    
    func clearLog() {
        log = []
    }
}

func share(url: URL, remove: Bool = false) -> Void {
    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    activityViewController.modalPresentationStyle = .popover
        if remove {
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
            }
        }
    }

    DispatchQueue.main.async {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootViewController = windowScene.windows.first?.rootViewController {
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = rootViewController.view
                    popoverController.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                                      y: rootViewController.view.bounds.midY,
                                                      width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                rootViewController.present(activityViewController, animated: true, completion: nil)
            } else {
                print("No root view controller found.")
            }
        } else {
            print("No window scene found.")
        }
    }
}
