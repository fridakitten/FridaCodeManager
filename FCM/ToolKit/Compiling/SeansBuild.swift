/* 
 SeansBuild.swift 

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
import SwiftUI

func build(_ ProjectInfo: Project,_ erase: Bool,_ status: Binding<String>?,_ progress: Binding<Double>?) -> Int {
    let info: [String] = ["\(ProjectInfo.ProjectPath)/Payload","\(ProjectInfo.ProjectPath)/Payload/\(ProjectInfo.Executable).app","\(ProjectInfo.ProjectPath)/Resources","\(global_sdkpath)/\(ProjectInfo.SDK)","\(ProjectInfo.ProjectPath)/clang","\(ProjectInfo.ProjectPath)/bridge.h","\(ProjectInfo.ProjectPath)/entitlements.plist","\(load("\(ProjectInfo.ProjectPath)/api.api"))"]
    //PayloadPath  info[0]
    //AppPath      info[1]
    //Resources    info[2]
    //SDKPath      info[3]
    //ClangPath    info[4]
    //ClangBridge  info[5]
    //Entitlements info[6]
    //API Text     info[7]

    //define build bash environment
    let bashenv: [String] = ["SDKROOT=\(info[3])","CPATH=\(Bundle.main.bundlePath)/include","LIBRARY_PATH=\(info[3])/usr/lib","FRAMEWORK_PATH=/System/Library/Frameworks:/System/Library/PrivateFrameworks"]

    //Processing API
    var apiextension: ext = ext(build: "", bef: "", aft: "", ign: "")
    if !info[7].isEmpty {
        apiextension = api(info[7], ProjectInfo)
    }

    //finding code files
    messenger(status,progress,"finding code files",0.1)
    let (MFiles, AFiles, SwiftFiles) = (FindFilesStack(ProjectInfo.ProjectPath, [".m", ".c", ".mm", ".cpp"], splitAndTrim(apiextension.ign) + ["Resources"]), FindFilesStack(ProjectInfo.ProjectPath, [".a"], splitAndTrim(apiextension.ign) + ["Resources"]), FindFilesStack(ProjectInfo.ProjectPath, [".swift"], splitAndTrim(apiextension.ign) + ["Resources"]))

    //finding frameworks
    messenger(status,progress,"finding frameworks",0.15)
    let frameworks = !MFiles.isEmpty && FileManager.default.fileExists(atPath: info[3]) ? findFrameworks(in: URL(fileURLWithPath: ProjectInfo.ProjectPath), SDKPath: info[3]) : []
    let frameflags = frameworks.map { "-framework \($0)" }.joined(separator: " ")

    //setting up command
    clearlog()
    messenger(status,progress,"setting up compiler",0.2)

    var EXEC = ""
    if !SwiftFiles.isEmpty {
        if !MFiles.isEmpty {
            EXEC += MFiles.map { mFile in
                "clang -fmodules \(apiextension.build) -target arm64-apple-ios\(ProjectInfo.TG) -c \(ProjectInfo.ProjectPath)/\(mFile) \(AFiles.joined(separator: " ")) -o '\(info[4])/\(UUID()).o' &>> \(global_documents)/log.txt ; "
            }.joined()
        }
        EXEC += """
        swiftc \(SwiftFiles.joined(separator: " ")) \(AFiles.joined(separator: " ")) \(MFiles.isEmpty ? "" : "clang/*.o") \(apiextension.build) \
        \(FileManager.default.fileExists(atPath: info[5]) ? "-import-objc-header '\(info[5])'" : "") -parse-as-library -target arm64-apple-ios\(ProjectInfo.TG) -o '\(info[1])/\(ProjectInfo.Executable)' &>> \(global_documents)/log.txt
        """
    } else {
        EXEC += """
        clang \(frameflags) -fmodules \(apiextension.build) -target arm64-apple-ios\(ProjectInfo.TG) \(MFiles.joined(separator: " ")) \(AFiles.joined(separator: " ")) \
        -o '\(info[1])/\(ProjectInfo.Executable)' &>> \(global_documents)/log.txt
        """
    }

    let (CDEXEC,CLEANEXEC) = ("cd '\(ProjectInfo.ProjectPath)'", "rm -rf '\(info[4])'; rm -rf '\(info[0])'")

    //compiling app
    printlog("FridaCodeManager \(global_version)\n ")
    _ = climessenger("info","App Name: \(ProjectInfo.Executable)\nBundleID: \(ProjectInfo.BundleID)\nSDK:      \(ProjectInfo.SDK)")
    if !info[7].isEmpty {
        _ = climessenger("api-call-fetcher","build: \(apiextension.build)\n \nexec-before: \(apiextension.bef)\n \nexec-after: \(apiextension.aft)\n \ncompiler-ignore-content: \(apiextension.ign)")
    }
    if !frameworks.isEmpty {
        _ = climessenger("framework-finder","\(frameworks.map { "\($0)" }.joined(separator: "\n"))")
    }
    cfolder(atPath: info[0])
    cfolder(atPath: info[1])
    cfolder(atPath: info[4])
    try? copyc(from: info[2], to: info[1])
    shell("rm '\(info[1])/DontTouchMe.plist'")

    if !apiextension.bef.isEmpty {
        messenger(status,progress,"running api-exec-stage (before)",0.3)
        if climessenger("api-exec-stage","","\(CDEXEC) ; \(apiextension.bef)",nil,bashenv) != 0 {
            _ = climessenger("error-occurred", "running api-exec-stage failed")
            shell(CLEANEXEC)
            return 1
        }
    }

    messenger(status,progress,"compiling \(ProjectInfo.Executable)",0.4)
    if climessenger("compiler-stage","","\(CDEXEC) ; \(EXEC)", nil, bashenv) != 0 {
        _ = climessenger("error-occurred","compiling \(ProjectInfo.Executable) failed")
        shell(CLEANEXEC)
        return 1
    }

    messenger(status,progress,"running api-exec-stage (after)",0.5)
    if !apiextension.aft.isEmpty {
        if climessenger("api-exec-stage","","\(CDEXEC) ; \(apiextension.aft)",nil,bashenv) != 0 {
            _ = climessenger("error-occurred", "running api-exec-stage failed")
            shell(CLEANEXEC)
            return 1
        }
    }
    messenger(status,progress,"compressing \(ProjectInfo.Executable) into .ipa archive",0.5)
    shell("ldid -S'\(info[6])' '\(info[1])/\(ProjectInfo.Executable)'")
    shell("\(CDEXEC) ; zip -r9q ./ts.ipa ./Payload")

    //installing app
    messenger(status,progress,"installing \(ProjectInfo.Executable)",0.7)
    if erase {
        let result: Int = shell("\(Bundle.main.bundlePath)/tshelper install '\(ProjectInfo.ProjectPath)/ts.ipa' > /dev/null 2>&1", uid: 0)
        _ = climessenger("install--stage","TrollStore Helper returned \(String(result))")
    }
    shell(CLEANEXEC)
    if erase {
        shell("rm '\(ProjectInfo.ProjectPath)/ts.ipa'")
        shell("killall '\(ProjectInfo.Executable)' > /dev/null 2>&1")
        OpenApp(ProjectInfo.BundleID)
    }
    return 0
}

func messenger(_ status: Binding<String>?,_ progress: Binding<Double>?,_ tstat: String,_  tproc: Double) {
    DispatchQueue.main.async {
        if let status = status, let progress = progress {
            status.wrappedValue = tstat
            withAnimation {
                progress.wrappedValue = tproc
            }
        }
    }
}

func splitAndTrim(_ inputString: String) -> [String] {
    // Split the input string by the delimiter ";"
    let parts = inputString.split(separator: ";")
    
    // Trim whitespaces from each part and return the resulting array
    let trimmedParts = parts.map { $0.trimmingCharacters(in: .whitespaces) }
    
    return trimmedParts
}
