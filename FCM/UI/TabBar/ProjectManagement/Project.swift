/* 
    Project.swift 

    Copyright (C) 2023, 2024 SparkleChan and SeanIsTethered
    Copyright (C) 2024 fridakitten

    This file is part of FridaCodeManager.

    FridaCodeManager is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FridaCodeManager is distributed in the hope that it will be useful
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FridaCodeManager. If not, see <https://www.gnu.org/licenses/>.
*/ 
    
import Foundation

struct Project: Identifiable {
    let id = UUID()
    var Name: String
    var BundleID: String
    var Version: String
    var ProjectPath: String
    var Executable: String
    var SDK: String
    var TG: String
}

func GetProjects() -> [Project] {
    do {
        var Projects: [Project] = []
        for Item in try FileManager.default.contentsOfDirectory(atPath: global_documents) {
            if let Info = NSDictionary(contentsOfFile: "\(global_documents)/\(Item)/Resources/Info.plist"),
               let BundleID = Info["CFBundleIdentifier"] as? String, let Version = Info["CFBundleVersion"] as? String,
               let Executable = Info["CFBundleExecutable"] as? String, let TG = Info["MinimumOSVersion"] as? String {

	        	if let Info2 = NSDictionary(contentsOfFile: "\(global_documents)/\(Item)/Resources/DontTouchMe.plist"), let SDK = Info2["SDK"] as? String, let Name = Info2["ProjectName"] as? String {
                	Projects.append(Project(Name: Name, BundleID: BundleID, Version: Version, ProjectPath: "\(global_documents)/\(Item)", Executable: Executable, SDK: SDK, TG: TG))
                }
            }
        }
        return Projects
    } catch {
        print(error)
        return []
    }
}

//TODO: Use NSDictionary!!
func MakeApplicationProject(_ Name: String, _ BundleID: String, SDK: String, type: Int) {
    if !(1 <= type <= 3) { return; }

    let v2uuid = UUID()
    do {
        let ResourcesPath = "\(global_documents)/\(v2uuid)/Resources"
        try FileManager.default.createDirectory(atPath: ResourcesPath, withIntermediateDirectories: true)
        FileManager.default.createFile(atPath: "\(ResourcesPath)/Info.plist", contents: Data(InfoPlist.replacingOccurences(of: "%(Name)", with: Name).replacingOccurences(of: "%(BundleID)", with: BundleID).replacingOccurences(of: "%(OSVer)", with: String(gosver() ?? "14.0")).utf8))
        FileManager.default.createFile(atPath: "\(ResourcesPath)/DontTouchMe.plist", contents: Data(DontTouchMe.replacingOccurences(of: "%(v2uuid)", with: v2uuid).replacingOccurences(of: "%(SDK)", with: SDK).utf8))
        switch(type) {
            case 1: // SwiftUI app
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data(authorgen(file: "My App.swift", content: swiftApp).utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: Data(authorgen(file: "ContentView.swift", content: contentView).utf8))
                break
            case 2: // UIKit app
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: authorgen("main.m", mainv).data(using: .utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myAppDelegate.h", contents: authorgen("myAppDelegate.h", apdh).data(using: .utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myAppDelegate.m", contents: authorgen("myAppDelegate.m", apd).data(using: .utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.h", contents: authorgen("myRootViewController.h", rvch).data(using: .utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/myRootViewController.m", contents: authorgen("myRootViewController.m", rvc).data(using: .utf8))
                break;
            case 3: // SwiftUI + ObjectiveC bridge app
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/My App.swift", contents: Data(authorgen(file: "My App.swift", content: swiftApp).utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/ContentView.swift", contents: objcswift.data(using: .utf8))
                FileManager.default.createFile(atPath:"\(global_documents)/\(v2uuid)/bridge.h", contents: Data(authorgen("bridge.h", "#import \"main.h\"").utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.h", contents: authorgen("main.h", mainh).data(using: .utf8))
                FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/main.m", contents: authorgen("main.m", mainm).data(using: .utf8))
        }
        FileManager.default.createFile(atPath: "\(global_documents)/\(v2uuid)/entitlements.plist", contents: Data(ents.utf8))
    } catch {
        print(error)
    }
}
