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

func exportProj(_ project: Project) {
    let modname = project.Executable.replacingOccurrences(of: " ", with: "_")
    shell("rm '\(global_documents)/\(modname).sproj' ; cd '\(global_documents)' ; zip -r \(modname).sproj '\(project.Name)'")
}

func exportApp(_ project: Project) {
    let result = build(project, false, nil, nil)
    let modname = project.Executable.replacingOccurrences(of: " ", with: "_")
    if result == 0 {
        shell("mv '\(global_documents)/\(project.Name)/ts.ipa' '\(global_documents)/\(modname).ipa'")
    }
}

func importProj() {
    let target: String = "\(global_documents)/target.sproj"
    if fe(target) {
        shell("cd '\(global_documents)' ; unzip '\(target)' ; rm '\(target)'")
    }
}
