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
    @Binding var hello: UUID
    @State private var Prefs: Bool = false
    @State private var Removal: Bool = false
    @State private var projname: String = ""
    @State private var projrname: String = ""
    @State private var pathstate: String = ""
    @State private var action: Int = 0

    @Binding var Projects: [Project]
    var body: some View {
        NavigationView {
            List {
                ForEach(Dictionary(grouping: Projects, by: { $0.TYPE }).sorted(by: { $0.key < $1.key }), id: \.key) { type, projects in
                    Section(header: Text(type)) {
                        ForEach(projects) { Project in
                            NavigationLink(destination: CodeSpace(ProjectInfo: Project, pathstate: $pathstate, action: $action)) {
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
                                            app_btn(Project)
                                        }) {
                                            Label("Export App", systemImage: "app")
                                        }
                                        Button(action: {
                                            proj_btn(Project)
                                        }) {
                                            Label("Export Project", systemImage: "archivebox")
                                        }
                                    }
                                    Button(action: {
                                        projname = Project.Name
                                        projrname = Project.Executable
                                        Prefs = true
                                    }) {
                                        Label("Project Preferences", systemImage: "gear")
                                    }
                                    Section {
                                        Button(role: .destructive, action: {
                                            projname = "\(global_documents)/\(Project.Name)"
                                            projrname = "Remove \"\(Project.Executable)\"?"
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                Removal = true
                                            }
                                        }) {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                                }
                           }
                       }
                    }
                }
            }
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
                    POBHeader(title: $projrname)
                    Spacer().frame(height: 10)
                    POButtonBar(cancel: Cancel_trigger, confirm: Removal_trigger)
                }
                .background(BackgroundClearView())
                .edgesIgnoringSafeArea([.bottom])
            }
        }
    }

    private func app_btn(_ Project: Project) -> Void {
        DispatchQueue.global(qos: .utility).async {
            ShowAlert(UIAlertController(title: "Building \(Project.Executable)", message: "", preferredStyle: .alert))
            if exportApp(Project) == 0 {
                DismissAlert {
                    let modname = Project.Executable.replacingOccurrences(of: " ", with: "_")
                    if let stabURL = URL(string: "file://\(global_container)/tmp/\(modname).ipa") {
                        share(url: stabURL)
                    }
                }
            } else { DismissAlert() }
        }
    }

    private func proj_btn(_ Project: Project) -> Void {
        DispatchQueue.global(qos: .utility).async {
            ShowAlert(UIAlertController(title: "Exporting \(Project.Executable)", message: "", preferredStyle: .alert))
            if exportProj(Project) == 0 {
                DismissAlert {
                    let modname = Project.Executable.replacingOccurrences(of: " ", with: "_")
                    if let stabURL = URL(string: "file://\(global_container)/tmp/\(modname).sproj") {
                        share(url: stabURL)
                    }
                }
            } else { DismissAlert() }
        }
    }

    private func Removal_trigger() -> Void {
        haptfeedback(1)
        _ = rm("\(projname)")
        hello = UUID()
        Removal = false
    }

    private func Cancel_trigger() -> Void {
        Removal = false
    }

    private func exportProj(_ project: Project) -> Int {
        let modname = project.Executable.replacingOccurrences(of: " ", with: "_")
        _ = rm("\(global_container)/tmp/\(modname).sproj")
        let result: Int = Int(libzip_zip("\(global_documents)/\(project.Name)","\(global_documents)/\(modname).sproj", true))
        if result == 0 {
            _ = mv("\(global_documents)/\(modname).sproj", "\(global_container)/tmp/\(modname).sproj")
        }
        return result
    }

    private func exportApp(_ project: Project) -> Int {
        #if !stock
        let result = build(project, false, nil, nil)
        #else
        let result = 0
        #endif
        let modname = project.Executable.replacingOccurrences(of: " ", with: "_")
        if result == 0 {
            _ = rm("\(global_container)/tmp/\(modname).ipa")
            _ = mv("\(global_documents)/\(project.Name)/ts.ipa", "\(global_container)/tmp/\(modname).ipa")
        }
        return result
    }

    private func share(url: URL) -> Void {
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)

        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                if let rootViewController = windowScene.windows.first?.rootViewController {
                    rootViewController.present(activityViewController, animated: true, completion: nil)
                } else {
                    print("No root view controller found.")
                }
            } else {
                print("No window scene found.")
            }
        }
    }
}

struct CodeSpace: View {
    @State var ProjectInfo: Project
    @State var buildv: Bool = false
    @Binding var pathstate: String
    @Binding var action: Int
    var body: some View {
        FileList(title: ProjectInfo.Executable, directoryPath: URL(fileURLWithPath: ProjectInfo.ProjectPath), buildv: $buildv, actpath: $pathstate, action: $action, project: ProjectInfo)
            .fullScreenCover(isPresented: $buildv) {
                switch ProjectInfo.TYPE {
                    case "Applications":
                       buildView(ProjectInfo: ProjectInfo, buildv: $buildv)
                    case "Utilities":
                       buildView(ProjectInfo: ProjectInfo, buildv: $buildv)
                    case "Sean16":
                       sean16View(ProjectInfo: ProjectInfo, buildv: $buildv)
                    default:
                       Spacer()
                }
            }
    }
}

struct buildView: View {
    @State var ProjectInfo: Project
    @Binding var buildv: Bool
    @State private var compiling: Bool = true
    @State private var status: String = ""
    @State private var progress = 0.0
    @State private var Log: [String] = []
    var body: some View {
        VStack {
            NeoLog()
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
                #if !stock
                let status = build(ProjectInfo, true, $status, $progress)
                #else
                let status = build(ProjectInfo, false, $status, $progress)
                #endif
                DispatchQueue.main.async {
                    if status == 0 {
                        #if !stock
                        if ProjectInfo.TYPE == "Applications" {
                            OpenApp(ProjectInfo.BundleID)
                        }
                        #else
                        print("[*] you have to export the app!\n")
                        #endif
                    }
                    withAnimation {
                        compiling = false
                    }
                }
            }
        }
    }
}

struct sean16View: View {
    @State var ProjectInfo: Project
    @Binding var buildv: Bool

    var body: some View {
        VStack {
            ScreenEmulator()
                .frame(width: screenWidth, height: screenWidth)
                .onAppear {
                    serialQueue.async {
                        runtime_sean16(ProjectInfo)
                    }
                }
            //NeoLog(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.height / 4)
            Spacer().frame(height: 25)
            Button( action: {
                send_cpu(1)
                buildv = false
            }){
                ZStack {
                    Rectangle()
                        .foregroundColor(.red)
                        .cornerRadius(15)
                    Text("Abort")
                        .foregroundColor(.white)
                }
            }
            .frame(width: UIScreen.main.bounds.width / 1.2, height: 50)
        }
    }
}

func copyToClipboard(text: String, alert: Bool? = true) {
    haptfeedback(1)
    if (alert ?? true) {ShowAlert(UIAlertController(title: "Copied", message: "", preferredStyle: .alert))}
    UIPasteboard.general.string = text
    if (alert ?? true) {DismissAlert()}
}
