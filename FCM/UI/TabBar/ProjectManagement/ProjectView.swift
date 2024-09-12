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
    @State var pathstate: String = ""
    @State var action: Int = 0
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(GetProjects()) { Project in
                        NavigationLink(destination: CodeSpace(ProjectInfo: Project, sdk: $sdk, pathstate: $pathstate, action: $action)) {
                            HStack {
                                PubImg(projpath: "\(global_documents)/\(Project.Name)")
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
                                            ShowAlert(UIAlertController(title: "Building \(Project.Executable)", message: "", preferredStyle: .alert))
                                            if exportApp(Project) == 0 {
                                                DismissAlert()
                                                let modname = Project.Executable.replacingOccurrences(of: " ", with: "_")
                                                if let stabURL = URL(string: "file://\(NSTemporaryDirectory())\(modname).ipa") {
                                                    share(url: stabURL)
                                                }
                                            } else { DismissAlert() }
                                        }
                                    }){
                                        Label("Export App", systemImage: "app")
                                    }
                                    Button(action: {
                                        let modname = Project.Executable.replacingOccurrences(of: " ", with: "_")
                                        exportProj(Project)
                                        if let stabURL = URL(string: "file://\(NSTemporaryDirectory())\(modname).sproj") {
                                            share(url: stabURL)
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
                                        projname = "\(global_documents)/\(Project.Name)"
                                        projrname = Project.Executable
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
                   RemovalPopup(isPresented: $Removal, name: $projrname, exec: $projname)
                }
                .background(BackgroundClearView())
                .onDisappear {
                    hello = UUID()
                }

            }
        }
    }
    func share(url: URL) {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
    
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let rootViewController = windowScene.keyWindow?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
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
    @Binding var pathstate: String
    @Binding var action: Int
    var body: some View {
        FileList(directoryPath: ProjectInfo.ProjectPath, nv: ProjectInfo.Executable, buildv: $buildv, builda: builda, actpath: $pathstate, action: $action)
            .fullScreenCover(isPresented: $buildv) {
                buildView(ProjectInfo: ProjectInfo, sdk: $sdk, buildv: $buildv)
            }
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
    @State private var Log: [String] = []
    var body: some View {
        VStack {
            //if console {
                NeoLog()
            //}
            Spacer().frame(height: 25)
            if !compiling {
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
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(UIColor.systemGray6))
                            .cornerRadius(15)
                VStack {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: UIScreen.main.bounds.width / 1.4)
                    .accentColor(.primary)
                Spacer().frame(height: 10)
                Text("\(status)")
                    .font(.system(size: 11, weight: .semibold))
                }
                }
                .frame(width: UIScreen.main.bounds.width / 1.2, height: 65)
            }
        }
        .disabled(compiling)
        .onAppear {
            DispatchQueue.global(qos: .utility).async {
                compiling = true
                _ = build(ProjectInfo, true, $status, $progress)
                DispatchQueue.main.async {
                    withAnimation {
                        compiling = false
                    }
                }
            }
        }
    }
}
