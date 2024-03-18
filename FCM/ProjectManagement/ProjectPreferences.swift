import SwiftUI

struct ProjPreferences: View {
    @Binding var ProjectName: String
    @Binding var hello: UUID
    @Binding var rname: String
    @State var FrameworkPath = "\(docsDir())/frameworks"
    @State var ProjectPath = ""
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: PrefsInfo(ProjectName: $ProjectName, hello: $hello)) {
                Label("App Information", systemImage: "list.bullet.rectangle")
                }
                NavigationLink(destination: Appeareance(projname: ProjectName,projpath: "\(docsDir())/\(ProjectName)")) {
                Label("Appeareance", systemImage: "paintbrush")
            }

NavigationLink(destination: asksdk(projpath: "\(docsDir())/\(ProjectName)")) {
                Label("SDK", systemImage: "sdcard")
}

NavigationLink(destination: Frameprefs(ProjectName: $ProjectName, FrameworkPath: $FrameworkPath, ProjectPath: $ProjectPath)) {
                Label("Frameworks", systemImage: "tray.2")
                }
            }
            .accentColor(.primary)
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("\(rname)")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                ProjectPath = "\(docsDir())/\(ProjectName)/Frameworks"
            }
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
                let doc = docsDir()
                PlistPath = "\(doc)/\(ProjectName)/Resources/Info.plist"
                AppName = (rplist(forKey: "CFBundleName", plistPath: PlistPath) ?? "")
                AppliName = (rplist(forKey: "CFBundleExecutable", plistPath: PlistPath) ?? "")
                BundleID = (rplist(forKey: "CFBundleIdentifier", plistPath: PlistPath) ?? "")
                Version = (rplist(forKey: "CFBundleVersion", plistPath: PlistPath) ?? "")
                MIOS = (rplist(forKey: "MinimumOSVersion", plistPath: PlistPath) ?? "")
                rfresh = UUID()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("App Information")
        .navigationBarTitleDisplayMode(.inline)
    }
    func save() {
                    wplist(value: AppName, forKey: "CFBundleName", plistPath: PlistPath)
                    wplist(value: AppliName, forKey: "CFBundleExecutable", plistPath: PlistPath)
                    wplist(value: BundleID, forKey: "CFBundleIdentifier", plistPath: PlistPath)
                    wplist(value: Version, forKey: "CFBundleVersion", plistPath: PlistPath)
                    wplist(value: Version, forKey: "CFBundleShortVersionString", plistPath: PlistPath)
                    wplist(value: MIOS, forKey: "MinimumOSVersion", plistPath: PlistPath)
    hello = UUID()
    }
}

struct Frameprefs: View {
    @Binding var ProjectName: String
    @Binding var FrameworkPath: String
    @Binding var ProjectPath: String
    @State var addview: Bool = false
    @State var puuid: UUID = UUID()
    var body: some View {
        VStack {
            PKG(directoryPath: ProjectPath)
            .id(puuid)
        }
        .navigationBarItems(trailing: Button(action: {
addview = true
            }) {
                Image(systemName: "plus")
            })
        .sheet(isPresented: $addview) {
            PKGSelect(directoryPath: FrameworkPath, ProjectName: $ProjectName, addview: $addview)
.onDisappear {
    puuid = UUID()
}
    }
    .navigationTitle("Frameworks")
            .navigationBarTitleDisplayMode(.inline)
  }
}

struct Appeareance: View {
    @State var projname: String
    @State var projpath: String
    @State var restrict: Bool = false
    @State var potrait: Bool = false
    @State var landscape: Bool = false
    var body: some View {
        List {
            ImgView(projpath: projpath)
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
        .navigationTitle("Appeareance")
        .navigationBarTitleDisplayMode(.inline)
    }
    func update() {
        let doc = docsDir()
        let proj = "\(doc)/\(projname)"
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
                 rmaplist(aname: array, path: plist)
            }
            caplist(aname: array, path: plist, arrayData: items)
            
        } else {
            if paeplist(aname: array, path: plist) {
                 rmaplist(aname: array, path: plist)
            }
        }
    }

    func config() {
        let doc = docsDir()
        let proj = "\(doc)/\(projname)"
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

    func itemExistsInPlist(item: String, arrayKey: String, plistPath: String) -> Bool {
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
    @State var sdk: String = ""
    var body: some View {
      List {
        Text("\(sdk)")
        NavigationLink(destination: SDKList(directoryPath: "/var/jb/opt/theos/sdks" ,sdk: $sdk)) {
    Text("Change")
}
        }
        .onChange(of: sdk) { _ in
            wplist(value: sdk, forKey: "SDK", plistPath: "\(projpath)/Resources/DontTouchMe.plist")
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