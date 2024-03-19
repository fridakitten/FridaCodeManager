 /* 
 PlistToolkit.swift 

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

func rplist(forKey key: String, plistPath: String) -> String? {
    // Attempt to read existing plist content
    if let plistDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any],
       let value = plistDict[key] as? String {
        return value
    } else {
        print("Error reading value from \(plistPath) for key: \(key)")
        return nil
    }
}

func wplist(value: Any, forKey key: String, plistPath: String) {
    var plistDict: [String: Any]

    // Attempt to read existing plist content
    if let existingDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] {
        plistDict = existingDict
    } else {
        // Create a new plist dictionary if the file doesn't exist
        plistDict = [String: Any]()
    }

    // Update the dictionary with the new value
    plistDict[key] = value

    // Write the updated dictionary back to the plist file
    if (plistDict as NSDictionary).write(toFile: plistPath, atomically: true) {
        print("Value successfully written to \(plistPath) for key: \(key)")
    } else {
        print("Error writing value to \(plistPath)")
    }
}

func paeplist(aname arrayName: String, path plistPath: String) -> Bool {
    guard let plistData = FileManager.default.contents(atPath: plistPath),
          let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
          let targetArray = plistDictionary[arrayName] as? [Any] else {
        return false
    }

    return targetArray is [Any]
}

func caplist(aname arrayName: String, path plistPath: String, arrayData: [Any]) {
    var plistDictionary: [String: Any] = [:]

    // Check if plist file already exists
    if let existingPlistData = FileManager.default.contents(atPath: plistPath),
       let existingPlist = try? PropertyListSerialization.propertyList(from: existingPlistData, options: [], format: nil) as? [String: Any] {
        plistDictionary = existingPlist
    }

    // Add the new array to the dictionary
    plistDictionary[arrayName] = arrayData

    // Save the updated dictionary to the plist file
    if let updatedPlistData = try? PropertyListSerialization.data(fromPropertyList: plistDictionary, format: .xml, options: 0) {
        do {
            try updatedPlistData.write(to: URL(fileURLWithPath: plistPath))
            print("Array '\(arrayName)' created successfully in plist file at '\(plistPath)'.")
        } catch {
            print("Error writing to plist file: \(error)")
        }
    } else {
        print("Error converting dictionary to plist data.")
    }
}

func rmaplist(aname arrayName: String, path plistPath: String) {
    guard var plistDictionary = try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: plistPath)), options: [], format: nil) as? [String: Any] else {
        print("Error reading plist file.")
        return
    }

    // Check if the array exists in the dictionary
    guard plistDictionary[arrayName] != nil else {
        print("Array '\(arrayName)' does not exist in the plist file.")
        return
    }

    // Remove the array from the dictionary
    plistDictionary.removeValue(forKey: arrayName)

    // Save the updated dictionary to the plist file
    if let updatedPlistData = try? PropertyListSerialization.data(fromPropertyList: plistDictionary, format: .xml, options: 0) {
        do {
            try updatedPlistData.write(to: URL(fileURLWithPath: plistPath))
            print("Array '\(arrayName)' and its items removed successfully from plist file at '\(plistPath)'.")
        } catch {
            print("Error writing to plist file: \(error)")
        }
    } else {
        print("Error converting dictionary to plist data.")
    }
}

func aiaplist(item: Any,aname arrayName: String,path plistPath: String) {
    guard var plistDictionary = try? PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: plistPath)), options: [], format: nil) as? [String: Any] else {
        print("Error reading plist file.")
        return
    }

    // Check if the array exists in the dictionary
    guard var targetArray = plistDictionary[arrayName] as? [Any] else {
        print("Array '\(arrayName)' does not exist in the plist file.")
        return
    }

    // Add the new item to the array
    targetArray.append(item)
    plistDictionary[arrayName] = targetArray

    // Save the updated dictionary to the plist file
    if let updatedPlistData = try? PropertyListSerialization.data(fromPropertyList: plistDictionary, format: .xml, options: 0) {
        do {
            try updatedPlistData.write(to: URL(fileURLWithPath: plistPath))
            print("Item '\(item)' added successfully to array '\(arrayName)' in plist file at '\(plistPath)'.")
        } catch {
            print("Error writing to plist file: \(error)")
        }
    } else {
        print("Error converting dictionary to plist data.")
    }
}

func rmplist(key: String, plistPath: String) {
    guard let dict = NSMutableDictionary(contentsOfFile: plistPath) else {
        print("Error: Unable to load plist file at \(plistPath)")
        return
    }

    dict.removeObject(forKey: key)
    
    if dict.write(toFile: plistPath, atomically: true) {
        print("Key '\(key)' deleted successfully from \(plistPath)")
    } else {
        print("Error: Unable to write changes to \(plistPath)")
    }
}