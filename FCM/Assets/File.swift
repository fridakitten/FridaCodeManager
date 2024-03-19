import Foundation

public func cfolder(atPath path: String) {
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

public func docsDir() -> String {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].path
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
    let fileManager = FileManager.default
    let directoryPath = (filePath as NSString).deletingLastPathComponent
    let newFilePath = (directoryPath as NSString).appendingPathComponent(newFileName)

    try fileManager.moveItem(atPath: filePath, toPath: newFilePath)
}