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

let screenHeight = UIScreen.main.bounds.height
let screenWidth = UIScreen.main.bounds.width

struct FileList: View {
    @State var directoryPath: String
    @State private var files: [URL] = []
    @State private var folders: [URL] = []
    @State private var quar: Bool = false
    @State private var selpath: String = ""
    @State private var showAlertmod: Bool = false
    @State private var fileName: String = ""
    @State private var newName: String = ""
    @State private var isRenaming: Bool = false
    @State private var oldName: String = ""
    @State private var selfile: String = ""
    @State private var selname: String = ""
    @State private var rename: Bool = false
    @State private var remove: Bool = false
    @State private var fbool: Bool = false
    @State var nv: String
    @Binding var buildv: Bool
    @State var builda: Bool
    @State var showfile: Bool = false
    @Binding var actpath: String
    @Binding var action: Int
    var body: some View {
        List {
            Section {
                ForEach(folders + files, id: \.self) { item in
                    if isDirectory(item) {
                        NavigationLink(destination: FileList(directoryPath: item.path, nv: item.lastPathComponent, buildv: $buildv, builda: false, actpath: $actpath, action: $action)) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.primary)
                                Text(item.lastPathComponent)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                selfile = item.lastPathComponent
                                rename = true
                            }) {
                                Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
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
                                Button(role: .destructive, action: {
                                    selfile = item.path
                                    selname = item.lastPathComponent
                                    remove = true
                                }) {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    } else {
                        HStack {
                            Button(action: {
                                selpath = item.path
                                if !gtypo(item: item.lastPathComponent) {
                                    quar = true
                                } else {
                                    fbool = true
                                }
                            }) {
                                HStack {
                                    HStack {
                                        ZStack {
                                            Image(systemName: "doc.fill")
                                                .foregroundColor(gcolor(item: item.lastPathComponent))
                                            VStack {
                                                Spacer().frame(height: 8)
                                                Text(gsymbol(item: item.lastPathComponent))
                                                    .font(.system(size: CGFloat(gsize(item: item.lastPathComponent)), weight: .bold))
                                                    .foregroundColor(Color(.systemBackground))
                                            }
                                        }
                                        Text(item.lastPathComponent)
                                        Spacer()
                                        Text("\(gfilesize(atPath: item.path)) KB")
                                            .font(.system(size: 10, weight: .semibold))
                                    }
                                }
                            }
                            .contextMenu {
                                Button(action: {
                                    selfile = item.lastPathComponent
                                    rename = true
                                }) {
                                    Label("Rename", systemImage: "rectangle.and.pencil.and.ellipsis")
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
                                    Button(role: .destructive, action: {
                                        selfile = item.path
                                        selname = item.lastPathComponent
                                        remove = true
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
        .onAppear {
            loadFiles()
        }
        .disabled(isRenaming)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(nv)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if builda == true {
                        Section {
                            Button(action: { buildv = true }) {
                                Label("Build", systemImage: "play.fill")
                            }
                        }
                    }
                    Section {
                        Button(action: { showAlertmod = true }) {
                            Label("Create", systemImage: "doc.fill.badge.plus")
                        }
                    }
                    if action > 0 {
                        Section {
                            Button(action: {
                                if action == 1 {
                                    shell("cp -r '\(actpath)' '\(directoryPath)'")
                                    action = 0
                                } else if action == 2 {
                                    shell("mv '\(actpath)' '\(directoryPath)/\(URL(fileURLWithPath: actpath).lastPathComponent)'")
                                    action = 0
                                }
                                haptfeedback(1)
                                loadFiles()
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
        .sheet(isPresented: $showAlertmod) {
            BottomPopupView {
               CreatePopupView(isPresented: $showAlertmod, filepath: $directoryPath)
            }
            .background(BackgroundClearView())
            .onDisappear {
                loadFiles()
            }
        }
        .sheet(isPresented: $rename) {
            BottomPopupView {
                RenamePopupView(isPresented: $rename, old: $selfile, directoryPath: $directoryPath)
            }
            .background(BackgroundClearView())
            .onDisappear {
                loadFiles()
            }
        }
        .sheet(isPresented: $remove) {
            BottomPopupView {
                RemovalPopup(isPresented: $remove, name: $selname, exec: $selfile)
            }
            .background(BackgroundClearView())
            .onDisappear {
                loadFiles()
            }
        }
        .fullScreenCover(isPresented: $quar) {
            CodeEditorView(quar: $quar, filePath: $selpath)
        }
        .fullScreenCover(isPresented: $fbool) {
            ImageView(imagePath: $selpath, fbool: $fbool)
        }
    }
    func copyf(_ sourcePath: String,_ destinationPath: String) {
        do {
            let sourceURL = URL(fileURLWithPath: sourcePath)
            let destinationURL = URL(fileURLWithPath: destinationPath)

            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("File copied successfully!")
        } catch {
            print("Error copying file: \(error.localizedDescription)")
        }
    }

    func gsymbol(item: String) -> String {
        let suffix = gsuffix(from: item)
        switch(suffix) {
            case "m":
                return ".\(suffix)"
            case "h":
                return ".\(suffix)"
            case "c":
                return ".\(suffix)"
            case "mm":
                return ".\(suffix)"
            case "cpp":
                return ".\(suffix)"
            default:
                return ""
        }
    }
    func gcolor(item: String) -> Color {
        let suffix = gsuffix(from: item)
        switch(suffix) {
            case "m":
                return Color.orange
            case "c":
                return Color.blue
            case "mm":
                return Color.yellow
            case "cpp":
                return Color.green
            case "swift":
                return Color.red
            case "h":
                return Color.secondary
            default:
                return Color.primary
        }
    }
    func gsize(item: String) -> Int {
        let suffix = gsuffix(from: item)
        switch(suffix) {
            case "m":
                return 8
            case "h":
                return 8
            case "c":
                return 8
            case "mm":
                return 5
            case "cpp":
                return 4
            default:
                return 0
        }
    }
    func gtypo(item: String) -> Bool {
        let suffix = gsuffix(from: item)
        switch(suffix) {
            case "png":
                return true
            case "jpg":
                return true
            case "jpeg":
                return true
            case "PNG":
                return true
            case "JPG":
                return true
            default:
                return false
        }
    }
    func loadFiles() {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: directoryPath)
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let fileURLsOnly = fileURLs.filter { url in
            !isDirectory(url) && url.lastPathComponent != "DontTouchMe.plist"}
            let folderURLs = fileURLs.filter { isDirectory($0) }
            folders = folderURLs
            files = fileURLsOnly
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let itemURL = (folders + files)[index]
            do {
                try FileManager.default.removeItem(at: itemURL)
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
        loadFiles()
    }
    func renameFile(atPath filePath: String, to newFileName: String) throws {
        let fileManager = FileManager.default
        let directoryPath = (filePath as NSString).deletingLastPathComponent
        let newFilePath = (directoryPath as NSString).appendingPathComponent(newFileName)
        try fileManager.moveItem(atPath: filePath, toPath: newFilePath)
    }
}

struct ImageView: View {
    @Binding var imagePath: String
    @Binding var fbool: Bool
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
                        .frame(width: screenWidth)
                }
                .navigationBarTitle("Image Viewer", displayMode: .inline)
                .navigationBarItems(leading:
                    Button(action: {
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
    @State private var folders: [URL] = []
    @State var directoryPath: String
    @Binding var sdk: String
    var body: some View {
        List {
            Section() {
                ForEach(folders, id: \.self) { folder in
                    Button( action: {
                        sdk = folder.lastPathComponent
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
            loadFiles()
        }
        .accentColor(.primary)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("SDKs")
        .navigationBarTitleDisplayMode(.inline)
    }
    func loadFiles() {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: directoryPath)
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let fileURLsOnly = fileURLs.filter { !isDirectory($0) }
            let folderURLs = fileURLs.filter { isDirectory($0) }
            folders = folderURLs
            files = fileURLsOnly
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
}

struct PKG: View {
    @State private var files: [URL] = []
    @State private var folders: [URL] = []
    @State var directoryPath: String
    var body: some View {
        List {
            Section() {
                ForEach(folders, id: \.self) { folder in
                    HStack {
                        Image(systemName: "tray.fill")
                        Text(folder.lastPathComponent)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .onAppear {
            loadFiles()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Packages")
        .navigationBarTitleDisplayMode(.inline)
    }
    func loadFiles() {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: directoryPath)
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let fileURLsOnly = fileURLs.filter { !isDirectory($0) }
            let folderURLs = fileURLs.filter { isDirectory($0) }
            folders = folderURLs
            files = fileURLsOnly
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let itemURL = (folders + files)[index]
            do {
                try FileManager.default.removeItem(at: itemURL)
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
        loadFiles()
    }
}

func gfilesize(atPath filePath: String) -> String {
    let fileURL = URL(fileURLWithPath: filePath)
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
            let fileSizeInKB = Double(fileSize) / 1024.0
            return String(format: "%.2f", fileSizeInKB)
        } else {
            return "0.00" // Unable to retrieve file size
        }
    } catch {
        return "0.00" // Error occurred while getting file attributes or file doesn't exist
    }
}
func isDirectory(_ fileURL: URL) -> Bool {
    var isDirectory: ObjCBool = false
    FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
    return isDirectory.boolValue
}