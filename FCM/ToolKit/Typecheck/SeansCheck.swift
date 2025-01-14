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
import Darwin

func typecheck(_ ProjectInfo: Project) -> Void {
    let info: [String] = ["\(ProjectInfo.ProjectPath)/Payload","\(ProjectInfo.ProjectPath)/Payload/\(ProjectInfo.Executable).app","\(ProjectInfo.ProjectPath)/Resources","\(global_sdkpath)/\(ProjectInfo.SDK)","\(ProjectInfo.ProjectPath)/clang","\(ProjectInfo.ProjectPath)/bridge.h","\(ProjectInfo.ProjectPath)/entitlements.plist","\(load("\(ProjectInfo.ProjectPath)/api.api"))"]
    //PayloadPath  info[0]
    //AppPath      info[1]
    //Resources    info[2]
    //SDKPath      info[3]
    //ClangPath    info[4]
    //ClangBridge  info[5]
    //Entitlements info[6]
    //API          info[7]

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: info[3]) {
       return
    }

    //define build bash environment
    let bashenv: [String] = ["SDKROOT=\(info[3])","CPATH=\(Bundle.main.bundlePath)/include","LIBRARY_PATH=\(info[3])/usr/lib","FRAMEWORK_PATH=/System/Library/Frameworks:/System/Library/PrivateFrameworks","HOME=\(global_container)/.cache/.\(ProjectInfo.SDK)"]

    var apiextension: ext = ext(build:"",build_sub: "",bef: "", aft:"", ign: "")
    if !info[7].isEmpty {
        apiextension = api(info[7], ProjectInfo)
    }

    //finding code files
    let (MFiles, AFiles, SwiftFiles) = (FindFilesStack(ProjectInfo.ProjectPath, [".m", ".c", ".mm", ".cpp"], splitAndTrim(apiextension.ign) + ["Resources"]), FindFilesStack(ProjectInfo.ProjectPath, [".a"], splitAndTrim(apiextension.ign) + ["Resources"]), FindFilesStack(ProjectInfo.ProjectPath, [".swift"], splitAndTrim(apiextension.ign) + ["Resources"]))

    var EXEC = ""
    if !SwiftFiles.isEmpty {
        if !MFiles.isEmpty {
            EXEC += MFiles.map { mFile in
                "clang -D\(ProjectInfo.Macro) -fmodules -fsyntax-only \(apiextension.build_sub) -target arm64-apple-ios\(ProjectInfo.TG) -c \(ProjectInfo.ProjectPath)/\(mFile) \(AFiles.joined(separator: " ")) ; "
            }.joined()
        }
        EXEC += """
        swiftc -typecheck -D\(ProjectInfo.Macro) \(apiextension.build) \(SwiftFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) \(AFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) \
        \(FileManager.default.fileExists(atPath: info[5]) ? "-import-objc-header '\(info[5])'" : "") -parse-as-library -target arm64-apple-ios\(ProjectInfo.TG)
        """
    } else {
        EXEC += "clang -D\(ProjectInfo.Macro) -fmodules -fsyntax-only \(apiextension.build) -target arm64-apple-ios\(ProjectInfo.TG) \(MFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) \(AFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " "))"
    }

    let (CDEXEC) = ("cd '\(ProjectInfo.ProjectPath)'")

    //typechecking
    _ = climessenger("","","\(CDEXEC) ; \(EXEC)", nil, bashenv)
}
