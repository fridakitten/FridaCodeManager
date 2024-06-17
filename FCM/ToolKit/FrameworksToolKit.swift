/* 
 FrameworksToolKit.swift 

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

func findFrameworks(in directory: URL, SDKPath: String) -> [String] {
    var frameworksSet = Set<String>()
    
    let fileManager = FileManager.default
    let resourceKeys: [URLResourceKey] = [.isDirectoryKey, .isRegularFileKey]
    let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]
    
    guard let directoryEnumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: resourceKeys, options: options) else {
        return []
    }
    
    for case let fileURL as URL in directoryEnumerator {
        do {
            let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
            
            if resourceValues.isRegularFile == true {
                let fileExtension = fileURL.pathExtension.lowercased()
                if ["h", "c", "cpp", "m", "mm"].contains(fileExtension) {
                    let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                    let frameworkMatches = extractFrameworks(from: fileContents)
                    frameworksSet.formUnion(frameworkMatches)
                }
            } else if resourceValues.isDirectory == true {
                // Continue the enumeration
            } else {
                directoryEnumerator.skipDescendants()
            }
        } catch {
            print("Error reading file \(fileURL): \(error)")
        }
    }
    //getting all frameworks
    var frameworks: [URL] = []
    do {
        frameworks = try fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(SDKPath)/System/Library/Frameworks"), includingPropertiesForKeys: nil) + fileManager.contentsOfDirectory(at: URL(fileURLWithPath: "\(SDKPath)/System/Library/PrivateFrameworks"), includingPropertiesForKeys: nil)
    } catch {
        print("Something happened wrong while unwrapping")
    }
    //extracting URLs and converting them to framework names
    let rawFW: [String] = frameworks.map { url in
        let lastPathComponent = url.lastPathComponent
        return lastPathComponent.deletingPathExtension()
    }
    //filtering stuff out that might got copied
    frameworksSet = frameworksSet.filter { rawFW.contains($0) }
    return Array(frameworksSet)
}

func extractFrameworks(from contents: String) -> Set<String> {
    let pattern = "#(?:import|include)\\s+<([^/]+)/[^>]+>"
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    let nsString = contents as NSString
    let matches = regex.matches(in: contents, options: [], range: NSRange(location: 0, length: nsString.length))
    
    var frameworksSet = Set<String>()
    for match in matches {
        if match.numberOfRanges == 2 {
            let framework = nsString.substring(with: match.range(at: 1))
            frameworksSet.insert(framework)
        }
    }
    
    return frameworksSet
}

extension String {
    func deletingPathExtension() -> String {
        return (self as NSString).deletingPathExtension
    }
}