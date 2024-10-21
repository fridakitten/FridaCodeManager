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

func api(_ text: String,_ Project:Project) -> ext {
    //api class
    let apiclass: String = tags(text,"api")

    //version Definition
    //lets you choose what version of the api you wanna use
    let usever = tags(apiclass,"version")

    //initialise stuff
    var (build, build_sub, before, after, ignore) = ("", "", "", "", "")

    //subclasses
    if usever == "1.1" {
        (build, build_sub, before, after, ignore) = (tags(apiclass,"build"), tags(apiclass,"build-object"),tags(apiclass,"exec-before"), tags(apiclass,"exec-after"), tags(apiclass,"compiler-ignore-content"))
    } else {
        //translation to old API
        (build, build_sub, before, after, ignore) = (tags(apiclass,"build"), tags(apiclass,"build"),tags(apiclass,"exec-before"), tags(apiclass,"exec-after"), tags(apiclass,"compiler-ignore-content"))
    }

    return ext(build: apicall(build,Project,false), build_sub: apicall(build_sub,Project,false), bef: apicall(before,Project,true), aft: apicall(after,Project,true), ign: apicall(ignore,Project,false))
}
