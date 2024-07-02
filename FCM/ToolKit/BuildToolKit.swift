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

func OpenApp(_ BundleID: String) {
    guard let obj = objc_getClass("LSApplicationWorkspace") as? NSObject else { return }
    let workspace = obj.perform(Selector(("defaultWorkspace")))?.takeUnretainedValue() as? NSObject
    workspace?.perform(Selector(("openApplicationWithBundleID:")), with: BundleID)
}

func FindFilesStack(_ projectPath: String, _ fileExtensions: [String], _ ignore: [String]) -> [String] {
    
    do {
        let (fileExtensionsSet, ignoreSet, allFiles) = (Set(fileExtensions), Set(ignore), try FileManager.default.subpathsOfDirectory(atPath: projectPath))

        var objCFiles: [String] = []
        
        for file in allFiles {
            if fileExtensionsSet.contains(where: { file.hasSuffix($0) }) &&
               !ignoreSet.contains(where: { file.hasPrefix($0) }) {
                objCFiles.append("'\(file)'")
            }
        }
        return objCFiles
    } catch {
        return []
    }
}