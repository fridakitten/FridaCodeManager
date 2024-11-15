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

@discardableResult func typecheck(_ ProjectInfo: Project, filePath: String, Content: String) -> String {
    let info: [String] = ["\(global_sdkpath)/\(ProjectInfo.SDK)","\(load("\(ProjectInfo.ProjectPath)/api.api"))"]
    //SDKPath      info[0]
    //API Text     info[1]

    let fileManager = FileManager.default

    if !fileManager.fileExists(atPath: info[0]) {
       return "\(filePath):1:0: error: target SDK is not installed";
    }

    var apiextension: ext = ext(build:"",build_sub: "",bef: "", aft:"", ign: "")
    if !info[1].isEmpty {
        apiextension = api(info[1], ProjectInfo)
    }

    var args: [String] = []

    // selected macro
    args.append("-D\(ProjectInfo.Macro)")

    // sdk root
    args.append("-isysroot")
    args.append("\(global_sdkpath)/\(ProjectInfo.SDK)")

    // include paths
    args.append("-I\(Bundle.main.bundlePath)/include")
    #if jailbreak
    args.append("-I\(jbroot)/usr/lib/clang/14.0.0/include")
    #endif

    // what we are building for
    args.append("-target")
    args.append("arm64-apple-ios\(ProjectInfo.TG)")

    // what the api extension wants to extend
    args += splitAndTrim(apiextension.build)

    // the file path we wanna typecheck
    args.append(filePath)

    return typecheckC(args, Content);
}

