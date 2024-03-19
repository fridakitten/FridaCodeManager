 /* 
 api.swift 

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

func apicall(_ text: String,_ proj:Project) -> String {
    var ret = text
    ret = ret.replacingOccurrences(of: "<ver>", with: "1.0.1")
    ret = ret.replacingOccurrences(of: "<bundle>", with: Bundle.main.bundlePath)
    ret = ret.replacingOccurrences(of: "<actionpath>", with: docsDir())
    ret = ret.replacingOccurrences(of: "<projpath>", with: "\(docsDir())/\(proj.Name)")
    ret = ret.replacingOccurrences(of: "<app>", with: "\(proj.Executable)")
    ret = repla(ret)
    ret = rsc(ret)
    return ret
}

func repla(_ inputString: String) -> String {
    return inputString.replacingOccurrences(of: "\n", with: " ; ")
}

func rsc(_ inputString: String) -> String {
    var trimmedString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedString.hasPrefix("; ") {
        trimmedString.removeFirst()
    }
    
    if trimmedString.hasSuffix(" ;") {
        trimmedString.removeLast()
    }
    
    return trimmedString
}
