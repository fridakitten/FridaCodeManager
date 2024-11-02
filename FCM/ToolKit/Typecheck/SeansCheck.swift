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

var typechecking: Bool = false

func typecheck(_ ProjectInfo: Project,_ erase: Bool,_ status: Binding<String>?,_ progress: Binding<Double>?) -> Int {
    DispatchQueue.main.sync {
        typechecking = true
    }

    let info: [String] = ["\(ProjectInfo.ProjectPath)/Payload","\(ProjectInfo.ProjectPath)/Payload/\(ProjectInfo.Executable).app","\(ProjectInfo.ProjectPath)/Resources","\(global_sdkpath)/\(ProjectInfo.SDK)","\(ProjectInfo.ProjectPath)/clang","\(ProjectInfo.ProjectPath)/bridge.h","\(ProjectInfo.ProjectPath)/entitlements.plist"]
    //PayloadPath  info[0]
    //AppPath      info[1]
    //Resources    info[2]
    //SDKPath      info[3]
    //ClangPath    info[4]
    //ClangBridge  info[5]
    //Entitlements info[6]

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: info[3]) {
       return 1;
    }

    //define build bash environment
    let bashenv: [String] = ["SDKROOT=\(info[3])","CPATH=\(Bundle.main.bundlePath)/include","LIBRARY_PATH=\(info[3])/usr/lib","FRAMEWORK_PATH=/System/Library/Frameworks:/System/Library/PrivateFrameworks","HOME=\(global_container)/.cache/.\(ProjectInfo.SDK)"]

    //finding code files
    let (MFiles, AFiles, SwiftFiles) = (FindFilesStack(ProjectInfo.ProjectPath, [".m", ".c", ".mm", ".cpp"], []), FindFilesStack(ProjectInfo.ProjectPath, [".a"], []), FindFilesStack(ProjectInfo.ProjectPath, [".swift"], []))

    //finding frameworks
    let frameworks = !MFiles.isEmpty && FileManager.default.fileExists(atPath: info[3]) ? findFrameworks(in: URL(fileURLWithPath: ProjectInfo.ProjectPath), SDKPath: info[3], ignorePaths: []) : []
    let frameflags = frameworks.map { "-framework \($0)" }.joined(separator: " ")

    var EXEC = ""
    if !SwiftFiles.isEmpty {
        if !MFiles.isEmpty {
            EXEC += MFiles.map { mFile in
                "clang -fmodules -fsyntax-only -target arm64-apple-ios\(ProjectInfo.TG) -c \(ProjectInfo.ProjectPath)/\(mFile) \(AFiles.joined(separator: " ")) ; "
            }.joined()
        }
        EXEC += """
        swiftc -typecheck \(SwiftFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) \(AFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) \(MFiles.isEmpty ? "" : "clang/*.o") \
        \(FileManager.default.fileExists(atPath: info[5]) ? "-import-objc-header '\(info[5])'" : "") -parse-as-library -target arm64-apple-ios\(ProjectInfo.TG)
        """
    } else {
        EXEC += "clang \(frameflags) -fmodules -fsyntax-only -target arm64-apple-ios\(ProjectInfo.TG) \(MFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " ")) \(AFiles.map { "\(ProjectInfo.ProjectPath)/\($0)" }.joined(separator: " "))"
    }

    let (CDEXEC) = ("cd '\(ProjectInfo.ProjectPath)'")

    //typechecking
    _ = climessenger("","","\(CDEXEC) ; \(EXEC)", nil, bashenv)

    DispatchQueue.main.sync {
        typechecking = false
    }

    return 0
}

