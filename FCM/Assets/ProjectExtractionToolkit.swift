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
    let doc = docsDir()
    let target = "\(doc)/\(project.Executable).sproj"
    if fileExists(path: target) {
        shell("rm '\(doc)/\(project.Executable).sproj'")
    }
    shell("cd '\(doc)' && zip -r '\(project.Executable).sproj' '\(project.Name)'")
}

func importProj() {
    let doc = docsDir()
    let target = "\(doc)/target.sproj"
    if fileExists(path: target) {
        shell("cd '\(doc)' && unzip '\(target)'")
        shell("rm '\(target)'")
    }
}

func fileExists(path: String) -> Bool {
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: path)
}