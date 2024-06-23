 /* 
 run.swift 

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
    
//
//SPARKCODE API
//made by. Frida and SeanIsTethered
//

func api(_ text: String,_ Project:Project) -> ext {
    //api class
    let apiclass: String = tags(text,"api")

    //build subclass
    let build: String = tags(apiclass,"build")

    //exec-before subclass
    let before: String = tags(apiclass,"exec-before")

    //exec-after subclass
    let after: String = tags(apiclass,"exec-after")

    //ignore subclass
    let ignore: String = tags(apiclass,"compiler-ignore-content")

    return ext(build: apicall(build,Project), bef: apicall(before,Project), aft: apicall(after,Project), ign: apicall(ignore,Project))
}