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

// Return a String? that has all items matching required suffix (if any), seperated using spaces.
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

// Find (Objective)C files stored in a folder, ignore cases are excluded.
func findObjCFilesStack(_ projectPath: String, _ ignore: [String]) -> [String] {
    
    do {
        var objCFiles: [String] = []
        
        let allFiles = try FileManager.default.subpathsOfDirectory(atPath: projectPath)
        
        for fileExtension in CLangExts {
            let files = allFiles
                .filter { $0.hasSuffix(fileExtension) }
                .filter { file in
                    ignore.isEmpty || !ignore.contains { file.hasPrefix($0) }
                }
                .map { "'\($0)'" }
            
            objCFiles.append(contentsOf: files)
        }
        
        return objCFiles
    } catch {
        return []
    }
}

// Checks if a file exists.
func fe(_ path: String) -> Bool {
    return FileManager.default.fileExists(atPath: path)
}
