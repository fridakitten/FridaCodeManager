 /* 
 SparksBuild.swift 

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
    
import Foundation
import UIKit
import SwiftUI

func build(_ ProjectInfo: Project, _ SDK: String,_ erase: Bool,_ status: Binding<String>?,_ progress: Binding<Double>?) -> Int {
    let PayloadPath = "\(ProjectInfo.ProjectPath)/Payload"
    let AppPath = "\(PayloadPath)/\(ProjectInfo.Executable).app"
    let Resources = "\(ProjectInfo.ProjectPath)/Resources"
    let SDKPath = "\(jbroot)/opt/theos/sdks/\(ProjectInfo.SDK)"
    let ClangPath = "\(ProjectInfo.ProjectPath)/clang"
    let ClangBridge = "\(ProjectInfo.ProjectPath)/bridge.h"
    let SwiftFiles = (FindFiles(ProjectInfo.ProjectPath, ".swift") ?? "")
    let MFiles = (findObjCFilesStack(ProjectInfo.ProjectPath) ?? [""])
    //compiler setup
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "setting up compiler"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.0
            }
        }
    }
    var EXEC = ""
    if SwiftFiles != "" {
        if !fe(ClangBridge) {
            EXEC += "swiftc -sdk '\(SDKPath)' \(SwiftFiles) -o '\(AppPath)/\(ProjectInfo.Executable)' -parse-as-library -suppress-warnings -target arm64-apple-ios\(ProjectInfo.TG)"
        } else {
            if MFiles != [] {
                for mFile in MFiles {
                EXEC += "clang -w -isysroot '\(SDKPath)' -framework UIKit -framework Foundation -target arm64-apple-ios\(ProjectInfo.TG) -c \(ProjectInfo.ProjectPath)/\(mFile) -o '\(ProjectInfo.ProjectPath)/clang/\(UUID()).o'; "
                }
                EXEC += "swiftc -sdk '\(SDKPath)' \(SwiftFiles) clang/*.o -o '\(AppPath)/\(ProjectInfo.Executable)' -parse-as-library -import-objc-header '\(ClangBridge)' -suppress-warnings -target arm64-apple-ios\(ProjectInfo.TG)"
            } else {
            EXEC += "swiftc -sdk '\(SDKPath)' \(SwiftFiles) -o '\(AppPath)/\(ProjectInfo.Executable)' -parse-as-library -import-objc-header '\(ClangBridge)' -suppress-warnings -target arm64-apple-ios\(ProjectInfo.TG)"
            }
        }
    } else if MFiles != [""] {
        EXEC += "clang -w -isysroot '\(SDKPath)' \(MFiles.joined(separator: " ")) -framework UIKit -framework Foundation -target arm64-apple-ios\(ProjectInfo.TG) -o '\(AppPath)/\(ProjectInfo.Executable)'"
    }
    let LDIDEXEC = "ldid -S'\(ProjectInfo.ProjectPath)/entitlements.plist' '\(AppPath)/\(ProjectInfo.Executable)'"
    var CLEANEXEC = ""
    if PayloadPath != "" {
        CLEANEXEC = "rm -rf '\(ClangPath)'; rm -rf '\(PayloadPath)'"
    }
    let RMEXEC = "rm '\(ProjectInfo.ProjectPath)/ts.ipa'"
    let CDEXEC = "cd '\(ProjectInfo.ProjectPath)'"
    let ZIPEXEC = "zip -r9q ./ts.ipa ./Payload"
    let INSTALL = "\(jbroot)/usr/bin/tshelper install '\(ProjectInfo.ProjectPath)/ts.ipa'"
    let Extension = load("\(ProjectInfo.ProjectPath)/api.txt")
    let ApiExt: ext = api(Extension,ProjectInfo)
    if ApiExt.before != "" {
        shell("\(CDEXEC) && \(ApiExt.before)")
    }
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "preparing compiler"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.05
            }
        }
    }
    //compiler start
    print("FridaCodeManager \(version)\n \n+++++++++++++++++++++++++++\nApp Name: \(ProjectInfo.Executable)\nBundleID: \(ProjectInfo.BundleID)\n+++++++++++++++++++++++++++\n ")
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "creating folders"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.1
            }
        }
    }
    cfolder(atPath: PayloadPath)
    cfolder(atPath: AppPath)
    cfolder(atPath: ClangPath)
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "copying app resources to folders"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.15
            }
        }
    }
    try? copyc(from: Resources, to: AppPath)
    print("+++++ compiler-stage ++++++")
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "compiling \(ProjectInfo.Executable)"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.2
            }
        }
    }
    if shell("\(CDEXEC) && \(EXEC)") != 0 {
        print("+++++++++++++++++++++++++++\n \n+++++++++ error +++++++++++\ncompiling \(ProjectInfo.Executable) failed\n+++++++++++++++++++++++++++")
        shell(CLEANEXEC)
        return 1
    }
    if ApiExt.after != "" {
        shell("\(CDEXEC) && \(ApiExt.after)")
    }
    print("+++++++++++++++++++++++++++\n \n+++++ install-stage +++++++")
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "giving entitlements to app"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.7
            }
        }
    }
    shell(LDIDEXEC)
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "compressing app into .ipa archive"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.75
            }
        }
    }
    shell("\(CDEXEC) && \(ZIPEXEC)")
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "installing \(ProjectInfo.Executable)"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 0.9
            }
        }
    }
    shell(INSTALL, uid: 0)
    usleep(100000)
    DispatchQueue.main.async {
        if let status = status {
            status.wrappedValue = "clean up"
        }
        if let progress = progress {
            withAnimation {
                progress.wrappedValue = 1.0
            }
        }
    }
    shell(CLEANEXEC)
    print("+++++++++++++++++++++++++++\n \n++++++++++ done +++++++++++")
    if erase == true {
        shell(RMEXEC)
        shell("killall '\(ProjectInfo.Executable)' > /dev/null 2>&1")
        OpenApp(ProjectInfo.BundleID)
    }
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