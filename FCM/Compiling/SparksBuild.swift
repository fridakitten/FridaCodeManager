import Foundation
import UIKit

func build(_ ProjectInfo: Project, _ SDK: String,_ erase: Bool) -> Int {
    let RootPath = "/var/jb"
    let TargetPath = ProjectInfo.ProjectPath
    let Executable = ProjectInfo.Executable
    let BundleID = ProjectInfo.BundleID
    let PayloadPath = "\(TargetPath)/Payload"
    let AppPath = "\(PayloadPath)/\(Executable).app"
    let Resources = "\(TargetPath)/Resources"
    let SDKPath = "\(RootPath)/opt/theos/sdks/\(ProjectInfo.SDK)"
    let ClangPath = "\(TargetPath)/clang"
    let ClangBridge = "\(TargetPath)/bridge.h"
    let SwiftFiles = (FindFiles(TargetPath, ".swift") ?? "")
    let MFiles = (findObjCFilesStack(TargetPath) ?? [""])
    let Extension: String = load("\(TargetPath)/extension.txt")
    let Object: ext = api(Extension,ProjectInfo)
    //compiler setup
    var EXEC = ""
    if SwiftFiles != "" {
        if !fe(ClangBridge) {
            EXEC += "swiftc -sdk '\(SDKPath)' \(SwiftFiles) -o '\(AppPath)/\(Executable)' -parse-as-library -suppress-warnings \(Object.flag)"
        } else {
            if MFiles != [] {
                for mFile in MFiles {
                EXEC += "clang -w -isysroot '\(SDKPath)' -framework UIKit -framework Foundation -c \(TargetPath)/\(mFile) -o '\(TargetPath)/clang/\(UUID()).o'; "
                }
                EXEC += "swiftc -sdk '\(SDKPath)' \(SwiftFiles) clang/*.o -o '\(AppPath)/\(Executable)' -parse-as-library -import-objc-header '\(ClangBridge)' -suppress-warnings \(Object.flag)"
            } else {
            EXEC += "swiftc -sdk '\(SDKPath)' \(SwiftFiles) -o '\(AppPath)/\(Executable)' -parse-as-library -import-objc-header '\(ClangBridge)' -suppress-warnings \(Object.flag)"
            }
        }
    } else if MFiles != [""] {
        EXEC += "clang -w -isysroot '\(SDKPath)' \(MFiles.joined(separator: " ")) -framework UIKit -framework Foundation -o '\(AppPath)/\(Executable)'"
    }
    let LDIDEXEC = "ldid -S'\(TargetPath)/entitlements.plist' '\(AppPath)/\(Executable)'"
    var CLEANEXEC = ""
    if PayloadPath != "" {
        CLEANEXEC = "rm -rf '\(ClangPath)'; rm -rf '\(PayloadPath)'"
    }
    let RMEXEC = "rm '\(TargetPath)/ts.ipa'"
    let CDEXEC = "cd '\(TargetPath)'"
    let ZIPEXEC = "zip -r9q ./ts.ipa ./Payload"
    let INSTALL = "\(RootPath)/usr/bin/tshelper install '\(TargetPath)/ts.ipa'"
    shell("\(CDEXEC) && \(Object.before)")
    //compiler start
    print("FridaCodeManager 1.0.1\n \n+++++++++++++++++++++++++++\nApp Name: \(Executable)\nBundleID: \(BundleID)\n+++++++++++++++++++++++++++\n ")
    cfolder(atPath: PayloadPath)
    cfolder(atPath: AppPath)
    cfolder(atPath: ClangPath)
    try? copyc(from: Resources, to: AppPath)
    print("+++++ compiler-stage ++++++")
    if shell("\(CDEXEC) && \(EXEC)") != 0 {
        print("+++++++++++++++++++++++++++\n \n+++++++++ error +++++++++++\ncompiling \(Executable) failed\n+++++++++++++++++++++++++++")
        shell(CLEANEXEC)
        return 1
    }
    print("+++++++++++++++++++++++++++\n \n+++++ install-stage +++++++")
    shell(LDIDEXEC)
    shell("\(CDEXEC) && \(ZIPEXEC)")
    shell(INSTALL, uid: 0)
    shell(CLEANEXEC)
    print("+++++++++++++++++++++++++++\n \n++++++++++ done +++++++++++")
    if erase == true {
        shell(RMEXEC)
        shell("killall '\(Executable)' > /dev/null 2>&1")
        OpenApp(BundleID)
    }
    shell("\(CDEXEC) && \(Object.after)")
    return 0
}

func OpenApp(_ BundleID: String) {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    workspace?.perform(Selector(("openApplicationWithBundleID:")), with: BundleID)
}

func copyf(sourcePath: String, destinationPath: String) {
    let fileManager = FileManager.default
    
    do {
        try! fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
    }
}

func FindFiles(_ ProjectPath: String, _ suffix: String) -> String? {
    do {
        var Files: [String] = []
        for File in try FileManager.default.subpathsOfDirectory(atPath: ProjectPath).filter({$0.hasSuffix(suffix)}) {
            Files.append("'\(File)'")
        }
        return Files.joined(separator: " ")
    } catch {
        return nil
    }
}

func findObjCFilesStack(_ projectPath: String) -> [String]? {
    let fileExtensions = [".m", ".c", ".mm", ".cpp"]
    
    do {
        var objCFiles: [String] = []
        
        for fileExtension in fileExtensions {
            let files = try FileManager.default.subpathsOfDirectory(atPath: projectPath)
                .filter { $0.hasSuffix(fileExtension) }
                .map { "'\($0)'" }
            
            objCFiles.append(contentsOf: files)
        }
        
        return objCFiles
    } catch {
        return nil
    }
}

func fe(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
}