 /* 
LogToolKit.swift 

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



func climessenger(_ title: String,_ text: String,_ command: String? = "",_ uid: uid_t? = 501,_ env: [String]? = []) -> Int {
    let marks: Int = (36 - title.count) / 2
    let slice = String(repeating: "+", count: marks)
    let command = command ?? "echo"
    var code = 0
    if command.isEmpty {
        printlog("\(slice) \(title) \(slice)\n\(text)\n++++++++++++++++++++++++++++++++++++++\n ")
    } else {
        printlog("\(slice) \(title) \(slice)")
        code = shell("\(command)",uid: (uid ?? 501), env: (env ?? []))
        printlog("++++++++++++++++++++++++++++++++++++++\n ")
    }
    return code
}

func printlog(_ text: String) {
    shell("echo -e \"\(text)\"")
}

func clearlog() {
    shell("echo -e \"\" > \(global_documents)/log.txt")
}