import SwiftUI
import UIKit
import QuickLook

struct ProjectView: View {
    @Binding var sdk: String
    @Binding var font: CGFloat
    @Binding var hello: UUID
    @State var Prefs: Bool = false
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
                        NavigationLink(destination: CodeSpace(ProjectInfo: Project, sdk: $sdk, font: $font)) {
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
    build(Project, sdk, false)
    DismissAlert()
    DispatchQueue.main.async {
    let doc = docsDir()
    let path = "\(doc)/ts.ipa"
    shell("rm '\(path)'")
    shell("mv '\(doc)/\(Project.Name)/ts.ipa' \(path)")
    if let fileURL = URL(string: "file://" + path) {
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
}
                        }
                    }
                    .onDelete { indexSet in
                        // Handle delete action here
                        if let firstIndex = indexSet.first {
                            let ProjectName = GetProjects()[firstIndex].Name
                            let ProjectPath = docsDir() + "/" + ProjectName
                            shell("rm -rf '\(ProjectPath)'")
                            hello = UUID()
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
    }
}
func fuck(url: URL) {
    let activityViewController =
UIActivityViewController(activityItems: [url], applicationActivities: nil)
    if let viewController =
UIApplication.shared.windows.first?.rootViewController {
viewController.present(activityViewController, animated: true, completion: nil)
}
}
}

//Codespace
struct CodeSpace: View {
    @State var ProjectInfo: Project
    @Binding var sdk: String
    @Binding var font: CGFloat
    @State var buildv: Bool = false
    @State var fcreate: Bool = false
    @State var builda: Bool = true
    var body: some View {
        FileList(directoryPath: ProjectInfo.ProjectPath, font: $font, nv: ProjectInfo.Executable, buildv: $buildv, builda: builda)
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
            ProgressView()
        }
        }
        .disabled(compiling)
        .onAppear {
      DispatchQueue.global(qos: .utility).async {
                compiling = true
                let result = build(ProjectInfo, sdk, true)
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