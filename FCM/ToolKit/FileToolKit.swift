 /* 
 File.swift 

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

func cfolder(atPath path: String) {
    do {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print("Error creating folder: \(error)")
    }
}

func cfile(atPath path: String, withContent content: String) {
    do {
        try content.write(toFile: path, atomically: true, encoding: .utf8)
        print("File created successfully at path: \(path)")
    } catch {
        print("Error creating file: \(error.localizedDescription)")
    }
}

func copyf(sourcePath: String, destinationPath: String) {        
    do {   
        try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
    } catch {
        print("Error creating file: \(error.localizedDescription)")
    }
}

func copyc(from sp: String, to dp: String) throws {
    let sourcePath = sp
    let destinationPath = dp

    let fileManager = FileManager.default
    
    // Check if the source path exists
    guard fileManager.fileExists(atPath: sourcePath) else {
        throw NSError(domain: "CopyContentsError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Source path not found"])
    }
    
    // Check if the destination path exists, create it if not
    if !fileManager.fileExists(atPath: destinationPath) {
        try fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
    }
    
    // Get contents of the source path
    let contents = try fileManager.contentsOfDirectory(atPath: sourcePath)
    
    // Copy each item to the destination path
    for item in contents {
        let sourceItemPath = (sourcePath as NSString).appendingPathComponent(item)
        let destinationItemPath = (destinationPath as NSString).appendingPathComponent(item)
        
        try fileManager.copyItem(atPath: sourceItemPath, toPath: destinationItemPath)
    }
}

func renameFile(atPath filePath: String, to newFileName: String) throws {
    let directoryPath = (filePath as NSString).deletingLastPathComponent
    let newFilePath = (directoryPath as NSString).appendingPathComponent(newFileName)
    try FileManager.default.moveItem(atPath: filePath, toPath: newFilePath)
}

func adv_rm(atPath path: String) throws {
    let protectedPaths: Set<String> = ["/", "/System", "/bin", "/sbin", "/usr", "/etc", "/var"]
    let normalizedPath = URL(fileURLWithPath: path).standardized.path
    
    guard !protectedPaths.contains(normalizedPath) else {
        throw NSError(domain: "com.example.FileManagerError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Attempted to remove contents from a protected system path: \(path)"])
    }

    let fileManager = FileManager.default
    let contents = try fileManager.contentsOfDirectory(atPath: normalizedPath)
    
    for item in contents {
        let itemPath = normalizedPath + "/" + item
        do {
            try fileManager.removeItem(atPath: itemPath)
        } catch {
            throw error
        }
    }
}

func rm(_ path: String) -> Int {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: path) {
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            return 2
        }
    } else {
        return 1
    }
    return 0
}

func mv(_ fromPath: String, _ toPath: String) -> Int {
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: fromPath) {
        do {
            try fileManager.moveItem(atPath: fromPath, toPath: toPath)
        } catch {
            return 2
        }
    } else {
        return 1
    }
    return 0
}
func cp(_ sourcePath: String,_ destinationPath: String) -> Int {
    let fileManager = FileManager.default
    
    do {
        guard fileManager.fileExists(atPath: sourcePath) else {
            return 1
        }
        
        if fileManager.fileExists(atPath: destinationPath) {
            try fileManager.removeItem(atPath: destinationPath)
        }
        
        try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
        
        return 0        
    } catch {
        return 1
    }
}
