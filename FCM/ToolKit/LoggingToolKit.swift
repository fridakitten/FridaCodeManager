import SwiftUI
import Foundation

// caches
let LogPipe = Pipe()
var errorcache: [logstruct] = []

class neolog_extern: NSObject {
    private(set) var LogItems: [LogItem] = []
    private(set) var LogViews: [logstruct] = []
    private var isActive: Bool = false

    // remember the old fds
    private let originalStdout: Int32
    private let originalStderr: Int32

    // remembering init
    override init() {
        // Save the original stdout and stderr file descriptors
        originalStdout = dup(STDOUT_FILENO)   // Duplicate the current stdout
        originalStderr = dup(STDERR_FILENO)   // Duplicate the current stderr
        super.init()
    }

    func start() -> Void {
        isActive = true

        LogPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let logData = fileHandle.availableData
            if !logData.isEmpty, let logString = String(data: logData, encoding: .utf8) {
                self.LogItems.append(LogItem(Message: logString))
            }
        }

        setvbuf(stdout, nil, _IOLBF, 0)
        setvbuf(stderr, nil, _IOLBF, 0)

        dup2(LogPipe.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        dup2(LogPipe.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
    }

    func stop() {
        LogPipe.fileHandleForReading.readabilityHandler = nil
        isActive = false

        dup2(originalStdout, STDOUT_FILENO) // Restore stdout
        dup2(originalStderr, STDERR_FILENO) // Restore stderr

        close(originalStdout)
        close(originalStderr)

        setvbuf(stdout, nil, _IOLBF, 0)
        setvbuf(stderr, nil, _IOLBF, 0)
    }

    // utilities
    func reflushcache() {
        errorcache = getlog(logitems: LogItems)
    }
}
