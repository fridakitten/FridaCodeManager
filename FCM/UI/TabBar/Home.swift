 /* 
 Home.swift 

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
import UIKit
import UniformTypeIdentifiers

struct Home: View {
    @State var fileimporter: Bool = false
    @State var showProj: Bool = false
    @Binding var SDK: String
    @State var app: String = ""
    @State var bundleid: String = ""
    @State var about: Bool = false
    @State var hello: UUID = UUID()
    @Binding var hellnah: UUID
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("changelog")) {
                    VStack {
                        Spacer().frame(height: 10)
                            ScrollView {
                                Text("""
1.3.8 (Fixes)
-rewrote parts of the framework finder(potentially crash fixes)
-made SparksBuild more efficient
-SparksBuild now prints out what the frameworks-finder finds
-fixed bug where Export App Feature won't check if the build process succeeds
-App/Project Exports will now use the tmp folder of the app container

1.3.7 (Fixes)
-framework finder will now safe unwrap the legal framework names
-in build process, MFiles is really empty now when you only have swift files

1.3.6 (Fixes)
-fixed compiling crash when SDK is missing
-made copy/move functions work over projects
-made default code editor font smaller
-inbuild copy buttons will show now a responsive popup
-author credit features added

1.3.5 (Fixes)
-fixed some highlighting performance issues
-fixed removing sdks
-using now app containers tmp folder for project imports
-fixed exporting app issues

1.3.4 (Fixes)
-updated highlighting engine(logic fixes)
-importing a new project will now change the uuid of the imported project(now you can import a project multiple times)
-stopped highlighting engine to calculate font types
-fixed bash environment
-SDK is not pre shipped anymore

1.3.3 (Fixes)
-now the automated framework finder will completely ignore illegal framework names avoiding compiling issues
-fixed a minor efficiency issue in the build process

1.3.2 (Optimisation)
-removed some duplicated functions
-made File Manager a bit more optimised
-switched to -F flag
-added automated framework finder for c languages

1.3.1 (Improvements)
-removed useless functions
-added haptic feedback to the popup
-added Copy/Move functions to File Manager
-redesigned settings page

1.3 (Features)
-fixed install happening on App Exportation
-added sdk download menu
-disabled auto correction in many new places

1.2.2 (Bug fixes)
-improved Settings
-updated Rename popup to feel more familiar
-added Debug Log for the Experts
-fixed a issues with loading images on Project View

1.2.1 (Bug fixes)
-improved a bit the Home View
-fixed a logic issue in Progess View
-removed Frameworks
-updated File actions UI
-fixed a spacing issue in the file presets

1.2 (New Horizon)
-added progress status
-added fixed icon setter appeareance issues
-made application version globally
-added a forgotten credit :3
-added forgotten highlights in code editor
-added roothide support
-fixed remark: issue
-stopped DontTouchMe.plist to copy over to App
-fixed export buttons

1.1 (Renew)
-changed name
-changed icon
-changed lists to be inset
-added Color to FileManagement
-changed the base design
-added Credits
-added variable detection to Highlighting engine
-implement libroot to get rootpath efficiently
-added HighlightRule cases
-updated Credits


1.0.1 (Fixup)
-added loading indication to the build view
-removed some unused or duplicated functions
-fixed multi-c-languages support
-critical files that could be harmful to your project are now hidden
-roothide support is now officially discontinued
-updated highlighting engine

1.0 (Initial Release)
-improved root spawning to conform todays security standards
-improved the way of interacting with your projects
-added first compile notice
-added Repo button for additional SDKs in About page

1.0 Beta 3 (Fixup)
-fixed alone headers with swift build combinations
-fixed folder renaming
-added persona capabilities to avoid roothelper needs
-improved the look of Project Preferences
-added a font family parser and added it to code editors font picker

1.0 Beta 2 (Fixup)
-made Projects use UUID as Name in order to create multiple projects with the same name
-fixed a log bug that was introduced in alpha 1
-added App Icon to the Projects List
-patched CFBundleDevelopmentRegion
-fixed importing projects on iOS 15
-fixed creating files in folders with no content
-made Project loading efficient instead of reloading on each appear

1.0 Beta 1 (Optimisations & Features)
-fixed Code editor calculating on main thread partially
-fixed a saving issue in the Project Preferences
-added feature to add app icons to projects
-added Image Viewer to FileManagement
-added a menu on console to copy error log
-added a font picker for the user to choose a font for the code editor
-added percentage to stats
-patched App Information in ProjectPreferences not loading on iOS 15 correctly

1.0 alpha 10 (Fixup & Features)
-added SDK settings in ProjectPreferences
-improved the way of finding jb root
-added a switch in settings to turn BSL(BackgroundSeperationLayer) in CodeEditor off
-added app icon

1.0 alpha 9 (Fixup & Improve)
-improved Colors
-added more highlighting for example comments, swift classes, values and more
-fixed "" highlighting in case an other highlightable object is inside the ""
-improved code editor button management
-fixed a issue where a user created app doesnt get terminated on update and reopened
-added checks to the Project Creation PopUp
-fixed some UI

1.0 alpha 8 (Fixup & Redesign)
-made navigationbar and tabbar visible
-fixed lag in codeeditor with some render techneques
-gave text a seperation shadow from the background
-updated the about page
-updated the highlighting engine to highlight some more stuff
-fixed a dumb memory leak in the code editor initialisation

1.0 alpha 7 (Fixup)
-fixed some memory leaks
-fixed a issue where a popup is not clear
-optimised build functions
-log now only appears on error
-added animations to the building process
-added stats
-addes file size indicators to the FileManagement
-added SFSymbol Viewer to settings
-changed default code editor font size to 15
-added forgoten symbol for C Files in FileManagement
-optimised Code editor

1.0 alpha 6 (Feature Update)
-added ObjectiveC support
-added Swift/ObjectiveC hybrid support
-added symbols to FileManagement
-fixed a bug where the navTitle is not inline in FileManagement
-added new mechanics to the building system
-added About
-fixed a Memory issue that kept filling the ram when opening a new file in codeeditor(hopefully)
-added extended memory support
-added additional C/C++/ObjC++ support
-added Dopamine 2.0 support

1.0 alpha 5 (Feature Update)
-added Project exporting
-added Project importing
-added Orientation restrictionn

1.0 alpha 4 (Compatiblity Update)
-updated much UI to conform iOS 15
-getting rid of SFSymbols on the Home View
-made the Code way more efficient thx to HAHALOSAH for bringing up sheet view and the ability to get rid of many Binding variables

1.0 alpha 3.1
-HAHALOSAH fixing rootless support real quick :)

1.0 alpha 3
-added support for multi string app names
-made file name appear in code editor
-made a PackageManager(Beta)
-added UI improvements replacing UIAlertController
-updated Project Preferences
-added App Exporting
-added rootless support

1.0 alpha 2.1 (fast fix)
-fixed ldid not changing app's entitlements

1.0 alpha 2 (major)
-optimised the efficiency of the Code Editor
-fixed default sdk issues
-fixed cd: too many arguments
-fixed project removal issues if app has an space in name(related: If project name has space it still won't work)
-disabled autocorrection on CodeEditor
-added Project Preferences
""")
                                    .font(.system(size: 11))
                                }
                                Spacer()
                            }
                            .frame(height: 200)
                        }
                        Section() {
                            Button( action: {
                                showProj = true
                                hellnah = UUID()
                            }){
                                listItem(label: "Create Project", systemImageName: "+", text: "Creates a FCM Project")
                            }
                            Button( action: {
                                $fileimporter.trampolineIfNeeded(to: true)
                            }){
                                listItem(label: "Import Project", systemImageName: "↑", text: "Imports a Project")
                            }
                        }
                        Button( action: {
                            hello = UUID()
                            about = true
                        }){
                            listItem(label: "About", systemImageName: "i", text: "Shows Information about this App")
                        }
                        .sheet(isPresented: $about) {
                            Frida(hello: $hello)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("FridaCodeManager")
                    .navigationBarTitleDisplayMode(.inline)
                    .fileImporter(isPresented: $fileimporter,allowedContentTypes: [.project]) { result in
                    do {
                        let fileURL = try result.get()
                        importProj(target: fileURL.path)
                        hellnah = UUID()
                    } catch {
                        print("Error importing file: \(error.localizedDescription)")
                    }
                }
            }
            .sheet(isPresented: $showProj) {
                BottomPopupView {
                    ProjPopupView(isPresented: $showProj, AppName: $app, BundleID: $bundleid, SDK: $SDK, hellnah: $hellnah)
                }
                .background(BackgroundClearView())
            }
        }
        func listItem(label: String, systemImageName: String, text: String) -> some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(label)
                        .font(.headline)
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                ZStack {
                Rectangle()
                    .foregroundColor(.secondary)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                Text(systemImageName)
                    .foregroundColor(Color(.systemBackground))
                    .frame(width: 20, height: 20)
                    .font(Font.custom("Menlo", size: 16).bold())
            }
        }
    }
    func handleFileImport(_ fileURL: URL) {
    do {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let targetURL = documentsURL.appendingPathComponent("target.sproj")

        try FileManager.default.copyItem(at: fileURL, to: targetURL)

        // Additional logic after successful import
        print("File copied successfully to \(targetURL)")
    } catch {
        print("Error handling file import: \(error.localizedDescription)")
    }
  }
}

extension UTType {
    static var project: UTType {
        UTType(filenameExtension: "sproj")!
    }
    static var all: UTType {
        UTType(filenameExtension: "txt")!
    }
}
