 /* 
 ProjectView.swift 

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
import QuickLook

struct ProjectView: View {
    @Binding var sdk: String
    @Binding var hello: UUID
    @State var Prefs: Bool = false
    @State var Removal: Bool = false
    @State var projname: String = ""
    @State var projrname: String = ""
    @State var ql: Bool = false
    @State var qls: String = ""
    @State var building: Bool = false
    @State var current: String = ""
    @State var doc: String = docsDir()
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(GetProjects()) { Project in
                        NavigationLink(destination: CodeSpace(ProjectInfo: Project, sdk: $sdk)) {
                            HStack {
                                PubImg(projpath: "\(doc)/\(Project.Name)")
                                Spacer().frame(width: 15)
                                VStack(alignment: .leading) {
                                    Text(Project.Executable)
                                        .font(.system(size: 16))
                                    Text(Project.BundleID)
                                        .font(.system(size: 12))
                                        .opacity(0.5)
                                }
                            }
                            .contextMenu {
                                Section {
                                    Button(action: {
                                        DispatchQueue.global(qos: .utility).async {
                                            ShowAlert(UIAlertController(title: "Building \(Project.Executable)...", message: "", preferredStyle: .alert))
                                            build(Project, sdk, false, nil, nil)
                                            DispatchQueue.main.async {
                                                let doc = docsDir()
                                                let path = "\(doc)/ts.ipa"
                                                shell("rm '\(path)'")
                                                shell("mv '\(doc)/\(Project.Name)/ts.ipa' \(path)")
                                                if let fileURL = URL(string: "file://" + path) {
                                                    DismissAlert()
                                                    fuck(url: fileURL)
                                                    print("File URL: \(fileURL)")
                                                } else {
                                                    print("Invalid file path")
                                                }
                                            }
                                        }
                                    }){
                                        Label("Export App", systemImage: "app.dashed")
                                    }
                                    Button(action: {
                                        exportProj(Project)
                                        let doc = docsDir()
                                        let target = "\(doc)/\(Project.Executable).sproj"
                                        if let fileURL = URL(string: "file://" + target) {
                                            fuck(url: fileURL)
                                            print("File URL: \(fileURL)")
                                        } else {
                                            print("Invalid file path")
                                        }
                                    }){
                                        Label("Export Project", systemImage: "archivebox")
                                    }
                                }
                                Button(action: {
                                    projname = Project.Name
                                    projrname = Project.Executable
                                    Prefs = true
                                }){
                                    Label("Project Preferences", systemImage: "gear")
                                }
                                Section {
                                    Button(role: .destructive, action: {
projname = Project.Executable
projrname = Project.Name
Removal = true
}){
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $building) {
                Alert(title: Text(NSLocalizedString("Building \(current)", comment: "")),
                      dismissButton: .none)
            }
            .id(hello)
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $Prefs) {
ProjPreferences(ProjectName: $projname, hello: $hello, rname: $projrname)
                .onDisappear {
                    hello = UUID()
                }
            }
            .sheet(isPresented: $Removal) {
                BottomPopupView {
                   RemovalPopup(isPresented: $Removal, name: $projname, exec: $projrname, hellnah: $hello)
                }
                .background(BackgroundClearView())
        }
    }
}
func fuck(url: URL) {
    let activityViewController =
UIActivityViewController(activityItems: [url], applicationActivities: nil)
    if let viewController = UIApplication.shared.windows.first?.rootViewController {
        viewController.present(activityViewController, animated: true, completion: nil)
    }
    }
}

//Codespace
struct CodeSpace: View {
    @State var ProjectInfo: Project
    @Binding var sdk: String
    @State var buildv: Bool = false
    @State var fcreate: Bool = false
    @State var builda: Bool = true
    var body: some View {
        FileList(directoryPath: ProjectInfo.ProjectPath, nv: ProjectInfo.Executable, buildv: $buildv, builda: builda)
        .fullScreenCover(isPresented: $buildv) {
    buildView(ProjectInfo: ProjectInfo, sdk: $sdk, buildv: $buildv)
        }
      }
    }
func ShowAlert(_ Alert: UIAlertController) {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.present(Alert, animated: true, completion: nil)
    }
}
func DismissAlert() {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController?.dismiss(animated: true)
    }
}

struct buildView: View {
    @State var ProjectInfo: Project
    @Binding var sdk: String
    @Binding var buildv: Bool
    @State var compiling: Bool = false
    @State var console: Bool = false
    @State var status: String = ""
    @State private var progress = 0.0
    var body: some View {
        VStack {
            LogView(show: $console)
            Spacer().frame(height: 25)
        if console == true {
            Button( action: {
buildv = false
}){
ZStack {
    Rectangle()
        .foregroundColor(compiling ? .gray : .blue)
        .cornerRadius(15)
    Text("Close")
        .foregroundColor(.white)
}
}
.frame(width: UIScreen.main.bounds.width / 1.2, height: 50)
        } else {
            Text("\(status)")
                .font(.system(size: 11, weight: .semibold))
            Spacer().frame(height: 10)
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 250)
        }
        }
        .disabled(compiling)
        .onAppear {
      DispatchQueue.global(qos: .utility).async {
                compiling = true
                let result = build(ProjectInfo, sdk, true, $status, $progress)
                if result != 0 {
                    withAnimation {
                        console = true
                    }
                } else {
                    buildv = false
                }
                compiling = false
            }
        }
    }
}
