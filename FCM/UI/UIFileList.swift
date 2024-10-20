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

private let invalidFS: Set<Character> = ["/", "\\", ":", "*", "?", "\"", "<", ">", "|"]

private enum ActiveSheet: Identifiable {
    case create, rename, remove

    var id: Int {
        hashValue
    }
}

struct FileProperty {
    // properties of a FileObject
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
                    Text("\(gfilesize(atPath: item.path)) KB")
                        .font(.system(size: 10, weight: .semibold))
            }
        }
    }
}

struct FileList: View {
    @State private var activeSheet: ActiveSheet?
    var directoryPath: URL
    @State private var files: [URL] = []
    @State private var quar: Bool = false
    @State private var selpath: String = ""
    @State private var selfile: String = ""
    @State private var selname: String = ""
    @State private var fbool: Bool = false
    var buildv: Binding<Bool>?
    var builda: Bool
    @Binding var actpath: String
    @Binding var action: Int

    @State private var potextfield: String = ""
    @State private var type: Int = 0
    var body: some View {
        List {
            Section {
                ForEach(files, id: \.self) { item in
                    HStack {
                        if isDirectory(item) {
                            NavigationLink(destination: FileList(directoryPath: item, buildv: nil, builda: false, actpath: $actpath, action: $action)) {
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
                        Button(action: {
                            selfile = item.lastPathComponent
                            potextfield = selfile
                            activeSheet = .rename
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
                                activeSheet = .remove
                            }) {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadFiles()
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(directoryPath.lastPathComponent)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if builda == true {
                        Section {
                            Button(action: {
                                if let buildv = buildv {
                                    buildv.wrappedValue = true
                                }
                            }) {
                                Label("Build", systemImage: "play.fill")
                            }
                        }
                    }
                    Section {
                        Button(action: { activeSheet = .create }) {
                            Label("Create", systemImage: "doc.fill.badge.plus")
                        }
                    }
                    if action > 0 {
                        Section {
                            Button(action: {
                                if action == 1 {
                                    cp(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
                                    action = 0
                                } else if action == 2 {
                                    mv(actpath, "\(directoryPath.path)/\(URL(fileURLWithPath: actpath).lastPathComponent)")
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
                case .create:
                    BottomPopupView {
                        POHeader(title: "Create")
                        POTextField(title: "Filename", content: $potextfield)
                        POPicker(function: create_selected, title: "Type", items: [PickerItems(id: 0, name: "File"), PickerItems(id: 1, name: "Folder")], type: $type)
                    }
                    .background(BackgroundClearView())
                    .edgesIgnoringSafeArea([.bottom])
                    .onDisappear {
                        loadFiles()
                    }
                case .rename:
                    BottomPopupView {
                        POHeader(title: "Rename")
                        POTextField(title: "Filename", content: $potextfield)
                        POButtonBar(cancel: dissmiss_sheet, confirm: rename_selected)
                    }
                    .background(BackgroundClearView())
                    .edgesIgnoringSafeArea([.bottom])
                    .onDisappear {
                        loadFiles()
                    }
                case .remove:
                    BottomPopupView {
                        POHeader(title: "Remove")
                        Spacer().frame(height: 10)
                        POButtonBar(cancel: dissmiss_sheet, confirm: remove_selected)
                    }
                    .background(BackgroundClearView())
                    .edgesIgnoringSafeArea([.bottom])
                    .onDisappear {
                        loadFiles()
                    }
                }
        }
        .fullScreenCover(isPresented: $quar) {
            CodeEditorView(quar: $quar, filePath: $selpath)
        }
        .fullScreenCover(isPresented: $fbool) {
            ImageView(imagePath: $selpath, fbool: $fbool)
        }
    }

    private func create_selected() -> Void {
        if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
            if(type == 0) {
                var content = ""
                switch gsuffix(from: potextfield) {
                    case "swift", "c", "m", "mm", "cpp", "h":
                        content = authorgen(file: potextfield)
                        break
                    default:
                        break
                }
                cfile(atPath: "\(directoryPath.path)/potextfield", withContent: content)
            } else {
                cfolder(atPath: "\(directoryPath.path)/potextfield")
            }
            haptfeedback(1)
            activeSheet = nil
        } else {
            haptfeedback(2)
        }
    }

    private func rename_selected() -> Void {
        if !potextfield.isEmpty && potextfield.rangeOfCharacter(from: CharacterSet(charactersIn: String(invalidFS))) == nil {
            _ = mv("\(directoryPath.path)/\(selfile)", "\(directoryPath.path)/\(potextfield)")
            haptfeedback(1)
            activeSheet = nil
        } else {
            haptfeedback(2)
        }
    }

    private func remove_selected() -> Void {
        _ = rm(selfile)
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

    private func loadFiles() -> Void {
        let fileManager = FileManager.default
        do {
            let items = try fileManager.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil)
            let fileURLs = items.filter { url in
            !isDirectory(url) && url.lastPathComponent != "DontTouchMe.plist"}
            let folderURLs = items.filter { isDirectory($0) }
            files = folderURLs + fileURLs
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }

    private func deleteItems(at offsets: IndexSet) -> Void {
        for index in offsets {
            let itemURL = (files)[index]
            do {
                try FileManager.default.removeItem(at: itemURL)
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
        loadFiles()
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
                        .frame(width: UIScreen.main.bounds.width)
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
    @State var directoryPath: String
    @Binding var sdk: String
    var body: some View {
        List {
            Section() {
                ForEach(files, id: \.self) { folder in
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

    private func loadFiles() {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: directoryPath)
        do {
            files = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        } catch {
            print("Error loading files: \(error.localizedDescription)")
        }
    }
}

private func gfilesize(atPath filePath: String) -> String {
    let fileURL = URL(fileURLWithPath: filePath)
    do {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        if let fileSize = attributes[FileAttributeKey.size] as? Int64 {
            let fileSizeInKB = Double(fileSize) / 1024.0
            return String(format: "%.2f", fileSizeInKB)
        } else {
            return "0.00"
        }
    } catch {
        return "0.00"
    }
}

private func isDirectory(_ fileURL: URL) -> Bool {
    var isDirectory: ObjCBool = false
    FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
    return isDirectory.boolValue
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
