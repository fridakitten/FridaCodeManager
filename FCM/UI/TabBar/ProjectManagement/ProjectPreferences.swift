 /* 
 ProjectPreferences.swift 

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

import SwiftUI

struct ProjPreferences: View {
    @Binding var ProjectName: String
    @Binding var hello: UUID
    @Binding var rname: String
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: PrefsInfo(ProjectName: $ProjectName, hello: $hello)) {
                    Label("App Information", systemImage: "list.bullet.rectangle.fill")
                }
                NavigationLink(destination: Appearance(projname: ProjectName,projpath: "\(global_documents)/\(ProjectName)")) {
                    Label("Appearance", systemImage: "paintbrush.fill")
                }
                NavigationLink(destination: asksdk(projpath: "\(global_documents)/\(ProjectName)")) {
                    Label("SDK", systemImage: "sdcard.fill")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("\(rname)")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PrefsInfo: View {
    @Binding var ProjectName: String
    @Binding var hello: UUID
    @State var PlistPath: String = ""
    @State var AppName: String = ""
    @State var AppliName: String = ""
    @State var BundleID: String = ""
    @State var Version: String = ""
    @State var MIOS: String = ""
    @State var rfresh: UUID = UUID()
    var body: some View {
        List {
            Section(header: Text("Application Name")) {
                TextField("Application Name", text: $AppliName)
                    .onSubmit {
                        save()
                    }
                }
                Section(header: Text("Display Name")) {
                TextField("Display Name", text: $AppName)
                    .onSubmit {
                        save()
                    }
                }
                Section(header: Text("BundleID")) {
                TextField("BundleID", text: $BundleID)
                    .onSubmit {
                        save()
                    }
                }
                Section(header: Text("Version")) {
                TextField("Version", text: $Version)
                    .onSubmit {
                        save()
                    }
                }
                Section(header: Text("Minimum Deployment Target")) {
                TextField("Minimum Deployment Target", text: $MIOS)
                    .onSubmit {
                        save()
                    }
              }
        }
        .id(rfresh)
        .onAppear {
            PlistPath = "\(global_documents)/\(ProjectName)/Resources/Info.plist"
            (AppName, AppliName, BundleID, Version, MIOS) = ((rplist(forKey: "CFBundleName", plistPath: PlistPath) ?? ""), (rplist(forKey: "CFBundleExecutable", plistPath: PlistPath) ?? ""), (rplist(forKey: "CFBundleIdentifier", plistPath: PlistPath) ?? ""), (rplist(forKey: "CFBundleVersion", plistPath: PlistPath) ?? ""), (rplist(forKey: "MinimumOSVersion", plistPath: PlistPath) ?? ""))
            rfresh = UUID()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("App Information")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() -> Void {
        let keys = ["CFBundleName", "CFBundleExecutable", "CFBundleIdentifier", "CFBundleVersion", "CFBundleShortVersionString", "MinimumOSVersion"]
        let values = [AppName, AppliName, BundleID, Version, Version, MIOS]

        for i in 0..<keys.count {
            _ = wplist(value: values[i], forKey: keys[i], plistPath: PlistPath)
        }

        hello = UUID()
    }
}

struct Appearance: View {
    @State var projname: String
    @State var projpath: String
    @State var restrict: Bool = false
    @State var potrait: Bool = false
    @State var landscape: Bool = false
    @State var iconid: UUID = UUID()
    var body: some View {
        List {
            ImgView(projpath: projpath,iconid: $iconid)
                .id(iconid)
            Section(header: Text("Orientation")) {
                Toggle("Restrict Orientation", isOn: $restrict)
                    .tint(.orange)
                if restrict == true {
                    Toggle("Portrait Mode", isOn: $potrait)
                    Toggle("Landscape Mode", isOn: $landscape)
                }
             }
         }
         .listStyle(InsetGroupedListStyle())
         .onAppear {
             config()
         }
         .onChange(of: restrict) { _ in
             update()
         }
         .onChange(of: potrait) { _ in
             update()
         }
         .onChange(of: landscape) { _ in
             update()
         }
         .navigationTitle("Appearance")
         .navigationBarTitleDisplayMode(.inline)
    }

    private func update() -> Void {
        let proj = "\(global_documents)/\(projname)"
        let plist = "\(proj)/Resources/Info.plist"
        let array = "UISupportedInterfaceOrientations"
        var items: [String] = []
        if restrict == true {
            if potrait == true {
                items.append("UIInterfaceOrientationPortrait")
            }
            if landscape == true {
                items.append("UIInterfaceOrientationLandscapeRight")
            }
            if paeplist(aname: array, path: plist) {
                _ = rmaplist(aname: array, path: plist)
            }
            _ = caplist(aname: array, path: plist, arrayData: items)
        } else {
            if paeplist(aname: array, path: plist) {
                 _ = rmaplist(aname: array, path: plist)
            }
        }
    }

    private func config() -> Void {
        let proj = "\(global_documents)/\(projname)"
        let plist = "\(proj)/Resources/Info.plist"
        let array = "UISupportedInterfaceOrientations"
        if paeplist(aname: array, path: plist) {
            restrict = true
            if itemExistsInPlist(item: "UIInterfaceOrientationPortrait", arrayKey: array, plistPath: plist) {
                potrait = true
            }
            if itemExistsInPlist(item: "UIInterfaceOrientationLandscapeRight", arrayKey: array, plistPath: plist) {
                landscape = true
            }
        } else {
            restrict = false
        }
    }

    private func itemExistsInPlist(item: String, arrayKey: String, plistPath: String) -> Bool {
        if let plistData = FileManager.default.contents(atPath: plistPath),
            let plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [String: Any],
        let array = plistDictionary[arrayKey] as? [String] {
            return array.contains(item)
        }
        return false
    }
}

struct asksdk: View {
    @State var projpath: String
    @State private var sdk: String = ""
    @State private var isActive: Bool = false
    var body: some View {
        List {
            Text("\(sdk)")
            NavigationLink(destination: SDKList(directoryPath: URL(fileURLWithPath: global_sdkpath) ,sdk: $sdk, isActive: $isActive), isActive: $isActive) {
                Text("Change")
            }
        }
        .onChange(of: sdk) { _ in
            _ = wplist(value: sdk, forKey: "SDK", plistPath: "\(projpath)/Resources/DontTouchMe.plist")
        }
        .onAppear {
            if sdk == "" {
                sdk = (rplist(forKey: "SDK", plistPath: "\(projpath)/Resources/DontTouchMe.plist") ?? "")
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("SDK")
        .navigationBarTitleDisplayMode(.inline)
    }
}
