 /* 
 altroot.swift 

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

func altroot(inPath path: String) -> URL? {
    do {
        let contents = try FileManager.default.contentsOfDirectory(atPath: path)

        for item in contents {
            if item.hasPrefix(".jbroot-"), let folderURL = URL(string: path)?.appendingPathComponent(item) {
                return folderURL
            }
        }
    } catch {
        print("Error while searching for .jbroot folder: \(error.localizedDescription)")
    }

    return URL(fileURLWithPath: "/")
}
