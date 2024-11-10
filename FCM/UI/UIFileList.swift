 /*
 UIFileList.swift

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
import Foundation
import UniformTypeIdentifiers

private let invalidFS: Set<Character> = ["/", "\\", ":", "*", "?", "\"", "<", ">", "|"]
let MacroMGR = MacroManager()

private enum ActiveSheet: Identifiable {
    case create, rename, remove, impSheet

    var id: Int {
        hashValue
    }
}

struct FileProperty {
    var symbol: String
    var color: Color
    var size: Int
}

struct FileObject: View {
    var properties: FileProperty
    var item: URL
    var body: some View {
        HStack {
            HStack {
                ZStack {
                    Image(systemName: "doc.fill")
                        .foregroundColor(properties.color)
                    VStack {
                        Spacer().frame(height: 8)
                        Text(properties.symbol)
                            .font(.system(size: CGFloat(properties.size), weight: .bold))
                            .foregroundColor(Color(.systemBackground))
                    }
                }
                Text(item.lastPathComponent)
                Spacer()
                    Text("\(gfilesize(atPath: item.path))")
                        .font(.system(size: 10, weight: .semibold))
            }
        }
    }
}

struct FileList: View {
    var title: String?
    var directoryPath: URL
    @State private var activeSheet: ActiveSheet?
    @State private var files: [URL] = []
    @State private var quar: Bool = false
    @State private var selpath: String = ""
    @State private var fbool: Bool = false
    var buildv: Binding<Bool>?
    @Binding var actpath: String
    @Binding var action: Int

    @State private var poheader: String = ""
    @State private var potextfield: String = ""
    @State private var type: Int = 0

    @Binding var project: Project

    @State private var macros: [String] = []
    @State private var cmacro: String = ""

    // GitHub
    @AppStorage("GIT_ENABLED") var enabled: Bool = false
    @AppStorage("GIT_TOKEN") var token: String = ""
    @AppStorage("GIT_USERNAME") var username: String = ""
    var body: some View {
        List {
            Section {
                ForEach(files, id: \.self) { item in
                    HStack {
                        if isDirectory(item) {
                            NavigationLink(destination: FileList(title: nil, directoryPath: item, actpath: $actpath, action: $action, project: $project)) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.primary)
                                    Text(item.lastPathComponent)
                                }
                            }
                        } else {
                            Button(action: {
                                selpath = item.path
                                if !gtypo(item: item.lastPathComponent) {
                                    quar = true
                                } else {
                                    fbool = true
                                }
                            }) {
                                FileObject(properties: gProperty(item), item: item)
                            }
                        }
                    }
                    .contextMenu {
                        Section {
                            Button(action: {
                                selpath = item.lastPathComponent
                                potextfield = selpath
                                activeSheet = .rename
                            }) {
                                Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
                            }
                        }
                        Section {
                            Button(action: {
                                actpath = item.path
                                action = 1
                            }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                            Button(action: {
                                actpath = item.path
                                action = 2
                            }) {
                                Label("Move", systemImage: "folder")
                            }
                        }
                        Section {
                            Button( action: {
                                share(url: item)
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        }
                        Section {
                            Button(role: .destructive, action: {
                                selpath = item.path
                                activeSheet = .remove
                                poheader = "Remove \"\(item.lastPathComponent)\"?"
                            }) {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .refreshable {
            await DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                withAnimation {
                    files = []
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    bindLoadFiles(directoryPath: directoryPath, files: $files)
                }
            }
        }
        .onAppear {
            bindLoadFiles(directoryPath: directoryPath, files: $files)

            if buildv != nil {
                if "\(project.ProjectPath)/Resources/DontTouchMe.plist" != MacroMGR.plistPath {
                    MacroMGR.plistPath = "\(project.ProjectPath)/Resources/DontTouchMe.plist"
                    MacroMGR.loadPlist()
                }

                macros = MacroMGR.getAllMacros()
                cmacro = MacroMGR.getCurrentMacro() ?? ""
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(
            title ?? directoryPath.lastPathComponent
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if let buildv = buildv {
                        Section {
                            Button(action: {
                                buildv.wrappedValue = true
                            }) {
                                Label("Build", systemImage: "play.fill")
                            }
                        }
                        Section {
                            ForEach(macros, id:\.self) { item in
                                Button( action: {
                                    cmacro = item
                                    MacroMGR.setCurrentMacro(to: item)
                                    MacroMGR.savePlist()
                                    project.Macro = cmacro
                                }) {
                                    if cmacro == item {
                                        Label {
                                            Text(item)
                                        } icon: {
                                            Image(systemName: "checkmark")
                                        }
                                    } else {
                                        Text(item)
                                    }
                                }
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        MacroMGR.removeMacro(item)
                                        MacroMGR.savePlist()
                                        if let index = macros.firstIndex(of: item) {
                                            macros.remove(at: index)
                                        }
                                    }) {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                            Button(action: {
                            }) {
                                Label("New Macro", systemImage: "plus")
                            }
                        }
                        if enabled {
                            Section {
                                if !FileManager.default.fileExists(atPath: "\(project.ProjectPath)/.git") {
                                    Button("Create Repo") {
                                        let result = createGitHubRepository(repositoryName: project.Executable, isPrivate: true, githubToken: token)
                                        if result == 0 {
                                            _ = shell("cd \(project.ProjectPath) && git init", uid: 501, env: [])
                                            _ = shell("cd \(project.ProjectPath) && git branch -M main", uid: 501, env: [])  // Ensure 'main' branch is created
                                            _ = shell("cd \(project.ProjectPath) && git add .", uid: 501, env: [])
                                            let remoteUrl = "https://\(username):\(token)@github.com/\(username)/\(project.Executable).git"
                                            _ = shell("cd \(project.ProjectPath) && git remote add origin \(remoteUrl)", uid: 501, env: [])
                                            let pushResult = shell("cd \(project.ProjectPath) && git push -u origin main", uid: 501, env: [])
                                            print("Push result: \(pushResult)")
                                            _ = shell("cd \(project.ProjectPath) && git commit -m \"Initial Commit\"", uid: 501, env: [])
                                            _ = shell("cd \(project.ProjectPath) && git push --set-upstream origin main", uid: 501, env: [])
                                        } else {
                                            print("Failed to create GitHub repository")
                                        }
                                    }
                                } else {
                                    Button("Commit") {
                                         _ = shell("cd \(project.ProjectPath) && git add .", uid: 501, env: [])
                                         _ = shell("cd \(project.ProjectPath) && git commit -m \"Update\"", uid: 501, env: [])
                                         _ = shell("cd \(project.ProjectPath) && git push", uid: 501, env: [])
                                    }
                                }
                            }
                        }
                    }
                    Section {
                        Button(action: {
                            activeSheet = .impSheet
                        }) {
                            Label("Import", systemImage: "square.and.arrow.down.fill")
                        }
                        Button(action: { activeSheet = .create }) {
                            Label("Create", systemImage: "doc.fill.badge.plus")
                        }
                    }
                    if action > 0 {
                        Section {
                            Button(action: {
                                if action == 1 {
                                    _ = cp(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                    action = 0
                                } else if action == 2 {
                                    _ = mv(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                    action = 0
                                }
                                haptfeedback(1)
                                bindLoadFiles(directoryPath: directoryPath, files: $files)
                            }) {
                                Label("Paste", systemImage: "doc.on.clipboard")
                            }
                        }
                    }
                } label: {
                    Label("", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            Group {
                if sheet != .impSheet {
                     BottomPopupView {
                         switch sheet {
                            case .create:
                                POHeader(title: "Create")
                                POTextField(title: "Filename", content: $potextfield)
                                POPicker(function: create_selected, title: "Type", arrays: [PickerArrays(title: "Type", items: [PickerItems(id: 0, name: "File"), PickerItems(id: 1, name: "Folder")])], type: $type)
                            case .rename:
                                POHeader(title: "Rename")
                                POTextField(title: "Filename", content: $potextfield)
                                POButtonBar(cancel: dissmiss_sheet, confirm: rename_selected)
                            case .remove:
                                POBHeader(title: $poheader)
                                Spacer().frame(height: 10)
                                POButtonBar(cancel: dissmiss_sheet, confirm: remove_selected)
                            default:
                                Spacer()
                        }
                    }
                } else {
                    DocumentPicker(pathURL: directoryPath)
                }
            }
            .background(BackgroundClearView())
            .edgesIgnoringSafeArea([.bottom])
            .onDisappear {
                poheader = ""
                potextfield = ""
                bindLoadFiles(directoryPath: directoryPath, files: $files)
            }
        }
        .fullScreenCover(isPresented: $quar) {
            NeoEditorHelper(isPresented: $quar, filepath: $selpath, project: project)
        }
        .fullScreenCover(isPresented: $fbool) {
            ImageView(imagePath: $selpath, fbool: $fbool)
        }
    }

    private func create_selected() -> Void {
        if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
            if type == 0 {
                var content = ""
                switch gsuffix(from: potextfield) {
                    case "swift", "c", "m", "mm", "cpp", "h", "hpp":
                        content = authorgen(file: potextfield)
                        break
                    default:
                        break
                }
                cfile(atPath: "\(directoryPath.path)/\(potextfield)", withContent: content)
            } else {
                cfolder(atPath: "\(directoryPath.path)/\(potextfield)")
            }
            haptfeedback(1)
            activeSheet = nil
        } else {
            haptfeedback(2)
        }
    }

    private func rename_selected() -> Void {
        if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
            _ = mv("\(directoryPath.path)/\(selpath)", "\(directoryPath.path)/\(potextfield)")
            haptfeedback(1)
            activeSheet = nil
        } else {
            haptfeedback(2)
        }
    }

    private func remove_selected() -> Void {
        _ = rm(selpath)
        haptfeedback(1)
        activeSheet = nil
    }

    private func dissmiss_sheet() -> Void {
        activeSheet = nil
    }

    private func gtypo(item: String) -> Bool {
        let suffix = gsuffix(from: item)
        switch(suffix) {
            case "png", "jpg", "jpeg", "PNG", "JPG":
                return true
            default:
                return false
        }
    }
}

struct ImageView: View {
    @Binding var imagePath: String
    @Binding var fbool: Bool

    init(imagePath: Binding<String>, fbool: Binding<Bool>) {
        _imagePath = imagePath
        _fbool = fbool
        UIInit(type: 1)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGray6)
                    .ignoresSafeArea()
                VStack {
                    Image(uiImage: loadImage())
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width)
                }
                .navigationBarTitle("Image Viewer", displayMode: .inline)
                .navigationBarItems(leading:
                    Button(action: {
                        UIInit(type: 0)
                        fbool = false
                    }) {
                        Text("Close")
                    }
                )
            }
        }
    }

    private func loadImage() -> UIImage {
        guard let image = UIImage(contentsOfFile: imagePath) else {
            return UIImage(systemName: "photo")!
        }
        return image
    }
}

struct SDKList: View {
    @State private var files: [URL] = []
    @State var directoryPath: URL
    @Binding var sdk: String
    @Binding var isActive: Bool
    var body: some View {
        List {
            Section {
                ForEach(files, id: \.self) { folder in
                    Button( action: {
                        sdk = folder.lastPathComponent
                        isActive = false
                    }){
                        HStack {
                            Image(systemName: "sdcard.fill")
                            Text(folder.lastPathComponent)
                        }
                    }
                }
            }
        }
        .onAppear {
            bindLoadFiles(directoryPath: directoryPath, files: $files)
        }
        .accentColor(.primary)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("SDKs")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private func gfilesize(atPath filePath: String) -> String {
    let fileURL = URL(fileURLWithPath: filePath)

    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)

        if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
            let fileSizeInBytes = Double(fileSize)
            let units = ["B", "KB", "MB", "GB", "TB"]
            var unitIndex = 0
            var adjustedSize = fileSizeInBytes

            while adjustedSize >= 1024 && unitIndex < units.count - 1 {
                adjustedSize /= 1024
                unitIndex += 1
            }

            return String(format: "%.2f %@", adjustedSize, units[unitIndex])
        } else {
            return "0.00 B"
        }
    } catch {
        return "0.00 B"
    }
}


private func isDirectory(_ url: URL) -> Bool {
    var isDir: ObjCBool = false
    return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
}

private func gProperty(_ fileURL: URL) -> FileProperty {
    var property: FileProperty = FileProperty(symbol: "", color: Color.black, size: 0)

    let suffix = gsuffix(from: fileURL.path)
    switch(suffix) {
        case "m":
            property.symbol = "m"
            property.color = Color.orange
            property.size = 8
        case "c":
            property.symbol = "c"
            property.color = Color.blue
            property.size = 8
        case "mm":
            property.symbol = "mm"
            property.color = Color.yellow
            property.size = 5
        case "cpp":
            property.symbol = "cpp"
            property.color = Color.green
            property.size = 4
        case "hpp":
            property.symbol = "hpp"
            property.color = Color.secondary
            property.size = 4
        case "swift":
            property.color = Color.red
        case "h":
            property.symbol = "h"
            property.color = Color.secondary
            property.size = 8
        case "api":
            property.symbol = "api"
            property.color = Color.purple
            property.size = 4
        default:
            property.color = Color.primary
    }

    return property
}

private func bindLoadFiles(directoryPath: URL, files: Binding<[URL]>) -> Void {
    let fileManager = FileManager.default

    DispatchQueue.global(qos: .background).async {
        do {
            let items = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)

            var fileGroups: [String: [URL]] = [:]

            for item in items {
                let fileExtension = item.pathExtension.lowercased()
                if !isDirectory(item) {
                    if fileGroups[fileExtension] == nil {
                        fileGroups[fileExtension] = []
                    }
                    fileGroups[fileExtension]?.append(item)
                }
            }

            DispatchQueue.main.async {
                withAnimation {
                    files.wrappedValue.removeAll { file in
                        !fileManager.fileExists(atPath: file.path)
                    }
                }
            }

            for item in items {
                if isDirectory(item) {
                    DispatchQueue.main.async {
                        if !files.wrappedValue.contains(item) {
                            withAnimation {
                                files.wrappedValue.append(item)
                            }
                        }
                    }
                    usleep(500)
                }
            }

            for (fileExtension, groupedFiles) in fileGroups.sorted(by: { $0.key < $1.key }) {
                for file in groupedFiles {
                    DispatchQueue.main.async {
                        if !files.wrappedValue.contains(file) {
                            withAnimation {
                                files.wrappedValue.append(file)
                            }
                        }
                    }
                    usleep(500)
                }
            }

        } catch {
            DispatchQueue.main.async {
                print("Error loading files: \(error.localizedDescription)")
            }
        }
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @State var pathURL: URL
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        documentPicker.allowsMultipleSelection = true
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            for item in urls {
                _ = mv(item.path, "\(parent.pathURL.path)/\(item.lastPathComponent)")
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
