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

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: info[3]) {
       print("SDK \"\(ProjectInfo.SDK)\" doesn't exist, make sure to download the SDK in Settings > SDK Hub\n")
       return 1;
    }

    #if !stock
    //define build bash environment
    let bashenv: [String] = ["SDKROOT=\(info[3])","CPATH=\(Bundle.main.bundlePath)/include","LIBRARY_PATH=\(info[3])/usr/lib","FRAMEWORK_PATH=/System/Library/Frameworks:/System/Library/PrivateFrameworks","HOME=\(global_container)/.cache/.\(ProjectInfo.SDK)"]
    #endif

    //Processing API
    var apiextension: ext = ext(build:"",build_sub: "",bef: "", aft:"", ign: "")
    if !info[7].isEmpty {
        apiextension = api(info[7], ProjectInfo)
    }

    print("FridaCodeManager \(global_version)\n ")
    _ = climessenger("info","App Name: \(ProjectInfo.Executable)\nBundleID: \(ProjectInfo.BundleID)\nSDK:      \(ProjectInfo.SDK)")

    //finding code files
    messenger(status,progress,"finding code files",0.1)
    let (MFiles, AFiles, SwiftFiles) = (FindFilesStack(ProjectInfo.ProjectPath, [".m", ".c", ".mm", ".cpp"], splitAndTrim(apiextension.ign) + ["Resources"]), FindFilesStack(ProjectInfo.ProjectPath, [".a"], splitAndTrim(apiextension.ign) + ["Resources"]), FindFilesStack(ProjectInfo.ProjectPath, [".swift"], splitAndTrim(apiextension.ign) + ["Resources"]))

    //finding frameworks
    messenger(status,progress,"finding frameworks", 0.15)
    let frameworks = !MFiles.isEmpty && FileManager.default.fileExists(atPath: info[3]) ? findFrameworks(in: URL(fileURLWithPath: ProjectInfo.ProjectPath), SDKPath: info[3], ignorePaths: splitAndTrim(apiextension.ign) + ["Resources"]) : []
    let frameflags = frameworks.map { "-framework \($0)" }.joined(separator: " ")

    //setting up command
    messenger(status,progress,"setting up compiler",0.2)

    var EXEC = ""
    if !SwiftFiles.isEmpty {
        #if jailbreak
        if !MFiles.isEmpty {
            EXEC += MFiles.map { mFile in
                "clang -fmodules \(apiextension.build_sub) -target arm64-apple-ios\(ProjectInfo.TG) -c \(ProjectInfo.ProjectPath)/\(mFile) \(AFiles.joined(separator: " ")) -o '\(info[4])/\(UUID()).o' ; "
            }.joined()
        }
        EXEC += """
        swiftc \(SwiftFiles.joined(separator: " ")) \(AFiles.joined(separator: " ")) \(MFiles.isEmpty ? "" : "clang/*.o") \(apiextension.build) \
        \(FileManager.default.fileExists(atPath: info[5]) ? "-import-objc-header '\(info[5])'" : "") -parse-as-library -target arm64-apple-ios\(ProjectInfo.TG) -o '\(info[1])/\(ProjectInfo.Executable)'
        """
        #elseif trollstore
        print("Swift is currently not supported on trollstore edition!\n")
        return 1
        #endif
    } else {
        #if jailbreak
        EXEC += """
        clang \(frameflags) -fmodules \(apiextension.build) -target arm64-apple-ios\(ProjectInfo.TG) \(MFiles.joined(separator: " ")) \(AFiles.joined(separator: " ")) \
        -o '\(info[1])/\(ProjectInfo.Executable)'
        """
        #elseif trollstore
        EXEC += """
        clang-16 \(frameflags) -fmodules \(apiextension.build) -target arm64-apple-ios\(ProjectInfo.TG) \(MFiles.joined(separator: " ")) \(AFiles.joined(separator: " ")) \
        -o '\(info[1])/\(ProjectInfo.Executable)'
        """
        #endif
    }

    let (CDEXEC) = ("cd '\(ProjectInfo.ProjectPath)'")

    //compiling app
    if !frameworks.isEmpty {
        _ = climessenger("framework-finder","\(frameworks.map { "\($0)" }.joined(separator: "\n"))")
    }

    cfolder(atPath: info[0])
    cfolder(atPath: info[1])
    cfolder(atPath: info[4])

    //has to move somewhere else
    #if !stock
    if !fileManager.fileExists(atPath: "\(global_container)/.cache") {
        cfolder(atPath: "\(global_container)/.cache")
    }
    if !fileManager.fileExists(atPath: "\(global_container)/.cache/.\(ProjectInfo.SDK)") {
        cfolder(atPath: "\(global_container)/.cache/.\(ProjectInfo.SDK)")
    }
    #endif

    try? copyc(from: info[2], to: info[1])
    _ = rm("\(info[1])/DontTouchMe.plist")

    #if !stock
    if !apiextension.bef.isEmpty {
        messenger(status,progress,"running api-exec-stage (before)",0.3)
        if climessenger("api-exec-stage","","\(CDEXEC) ; \(apiextension.bef)",nil,bashenv) != 0 {
            _ = climessenger("error-occurred", "running api-exec-stage failed")
            _ = rm(info[0])
            _ = rm(info[4])
            return 1
        }
    }
    messenger(status,progress,"compiling \(ProjectInfo.Executable)",0.4)
    if climessenger("compiler-stage","","\(CDEXEC) ; \(EXEC)", nil, bashenv) != 0 {
        _ = climessenger("error-occurred","compiling \(ProjectInfo.Executable) failed")
        _ = rm(info[0])
        _ = rm(info[4])
        return 1
    }
    #else
    // -->>> magic compiler <<<--
    sethome(to: "\(global_documents)")
    for file in MFiles {
        //compile
        dyexec("\(Bundle.main.bundlePath)/toolchain/bin/clang.dylib", "clang -v \(apiextension.build) -I\(Bundle.main.bundlePath)/toolchain/lib/clang/16.0.0/include -isysroot \(info[3]) -target arm64-apple-ios\(ProjectInfo.TG) -c \(ProjectInfo.ProjectPath)/\(file) -o \(info[4])/\(UUID()).o")
    }
    //final object files
    let ofiles = FindFilesStack(ProjectInfo.ProjectPath, [".o"], splitAndTrim(apiextension.ign) + ["Resources"])
    dyexec("\(Bundle.main.bundlePath)/toolchain/bin/ld.dylib", "ld -mno-snapshot -v -r \(ofiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) -syslibroot \(info[3]) \(frameflags) -o \(info[4])/final.o")
    //MachO!
    dyexec("\(Bundle.main.bundlePath)/toolchain/bin/ld.dylib", "ld -mno-snapshot -v \(info[4])/final.o -syslibroot \(info[3]) \(frameflags) -o \(info[1])/\(ProjectInfo.Executable)")
    sethome(to: "\(global_container)")
    // -->>> magic ending <<<--
    #endif

    #if !stock
    messenger(status,progress,"running api-exec-stage (after)",0.5)
    if !apiextension.aft.isEmpty {
        if climessenger("api-exec-stage","","\(CDEXEC) ; \(apiextension.aft)",nil,bashenv) != 0 {
            _ = climessenger("error-occurred", "running api-exec-stage failed")
            _ = rm(info[0])
            _ = rm(info[4])
            return 1
        }
    }
    #endif
    messenger(status,progress,"compressing \(ProjectInfo.Executable) into .ipa archive",0.5)
    #if !stock
    shell("ldid -S'\(info[6])' '\(info[1])/\(ProjectInfo.Executable)'")
    #endif

    libzip_zip("\(ProjectInfo.ProjectPath)/Payload", "\(ProjectInfo.ProjectPath)/ts.ipa", true)

    //installing app
    messenger(status,progress,"installing \(ProjectInfo.Executable)",0.7)
    var result: Int = 0
    #if !stock
    if erase {
        result = shell("\(Bundle.main.bundlePath)/tshelper install '\(ProjectInfo.ProjectPath)/ts.ipa' > /dev/null 2>&1", uid: 0)
        _ = climessenger("install--stage","TrollStore Helper returned \(String(result))")
    }
    #endif
    _ = rm(info[0])
    _ = rm(info[4])
    if erase {
        #if !stock
        pkill(ProjectInfo.Executable)
        #endif
        _ = rm("\(ProjectInfo.ProjectPath)/ts.ipa")
    }
    #if !stock
    return result
    #else
    return 0
    #endif
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

#if stock
func sethome(to newHome: String) {
    let result = setenv("HOME", newHome, 1)
    
    if result == 0 {
        print("[sethome] \(newHome)\n")
    } else {
        print("[sethome] fault")
    }
}
#endif
