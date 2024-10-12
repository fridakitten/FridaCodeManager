 /* 
 tag.swift 

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

struct ext {
    let build: String
    let build_sub: String
    let bef: String
    let aft: String
    let ign: String
}

func tags(_ inputString: String,_ tag: String) -> String {
    do {
        let regex = try NSRegularExpression(pattern: "<\(tag)>(.*?)</\(tag)>", options: .dotMatchesLineSeparators)
        if let match = regex.firstMatch(in: inputString, options: [], range: NSRange(location: 0, length: inputString.utf16.count)) {
            if let range = Range(match.range(at: 1), in: inputString) {
                return String(inputString[range])
            }
        }
    } catch {
        print("Error creating regular expression: \(error.localizedDescription)")
    }
    
    return ""
}