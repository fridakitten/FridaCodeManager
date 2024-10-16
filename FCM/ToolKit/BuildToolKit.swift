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

#if !stock
// private api function group to open arbitary apps
func obfuscatedClass(_ className: String) -> AnyClass? {
    return NSClassFromString(className)
}

func obfuscatedSelector(_ selectorName: String) -> Selector? {
    return NSSelectorFromString(selectorName)
}

func OpenApp(_ bundleID: String) {
    guard let workspaceClass = obfuscatedClass("LSApplicationWorkspace") as? NSObject.Type else {
        print("Failed to find LSApplicationWorkspace")
        return
    }
    
    guard let defaultWorkspaceSelector = obfuscatedSelector("defaultWorkspace") else {
        print("Failed to find defaultWorkspace selector")
        return
    }
    
    let workspace = workspaceClass.perform(defaultWorkspaceSelector)?.takeUnretainedValue() as? NSObject
    
    guard let openAppSelector = obfuscatedSelector("openApplicationWithBundleID:") else {
        print("Failed to find openApplicationWithBundleID selector")
        return
    }
    
    if let workspace = workspace {
        let result = workspace.perform(openAppSelector, with: bundleID)
        if result == nil {
            print("Failed to open app with bundle ID \(bundleID)")
        }
    } else {
        print("Failed to initialize LSApplicationWorkspace")
    }
}
#endif

func FindFilesStack(_ projectPath: String, _ fileExtensions: [String], _ ignore: [String]) -> [String] {
    do {
        let (fileExtensionsSet, ignoreSet, allFiles) = (Set(fileExtensions), Set(ignore), try FileManager.default.subpathsOfDirectory(atPath: projectPath))

        var objCFiles: [String] = []

        for file in allFiles {
            if fileExtensionsSet.contains(where: { file.hasSuffix($0) }) &&
               !ignoreSet.contains(where: { file.hasPrefix($0) }) {
                #if !stock
                objCFiles.append("'\(file)'")
                #else
                objCFiles.append("\(file)")
                #endif
            }
        }
        return objCFiles
    } catch {
        return []
    }
}
