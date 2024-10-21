 /* 
Font.swift 

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

import UIKit

func guif() -> [String] {
    var fontFamilies = UIFont.familyNames
    fontFamilies.sort { (family1, family2) in
        if family1.lowercased() == "menlo" {
            return true
        } else if family2.lowercased() == "menlo" {
            return false
        }
        return family1.lowercased() < family2.lowercased()
    }
    return fontFamilies
}

func gsuffix(from fileName: String) -> String {
    let trimmedFileName = fileName.replacingOccurrences(of: " ", with: "")
    let suffix = URL(string: trimmedFileName)?.pathExtension
    return suffix ?? ""
}
