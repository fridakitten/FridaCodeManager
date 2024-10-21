 /* 
 ProjectExtractionToolkit.swift 

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

func importProj(target: String) -> Void {
    let v2uuid: String = "\(UUID())"
    if FileManager.default.fileExists(atPath: target) {
        if libzip_unzip(target, "\(global_container)/tmp/\(v2uuid)") != 0 {
            return
        }
    } else {
        return
    }
    cfolder(atPath: "\(global_container)/tmp/\(v2uuid)")
    let content: [URL] = try! FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: "\(global_documents)/../tmp/\(v2uuid)"), includingPropertiesForKeys: nil)
    let projpath: String = content[0].path
    print("\nfound at: \(projpath)")
    if FileManager.default.fileExists(atPath: "\(projpath)/Resources/DontTouchMe.plist") {
       _ =  wplist(value: v2uuid, forKey: "ProjectName", plistPath: "\(projpath)/Resources/DontTouchMe.plist")
       _ =  mv("\(projpath)", "\(global_documents)/\(v2uuid)")
    }
    _ = rm("\(global_container)/tmp/\(v2uuid)")
}
