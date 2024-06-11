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
    //before tag
    let fcmclass: String = tags(text,"fcm")
    var before: String = tags(fcmclass,"bef")
    before = apicall(before,Project)
    //build tag
    var build: String = tags(fcmclass,"build")
    build = apicall(build,Project)
    //after tag
    var after: String = tags(fcmclass,"aft")
    after = apicall(after,Project)

    return ext(before:before,flag:build,after:after)
}