 /* 
 Settings.swift 

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

struct Settings: View {
    @Binding var sdk: String
    @Binding var bsl: Bool
    @Binding var fname: String
    @State var fontstate: CGFloat = {
        if let savedFont = UserDefaults.standard.value(forKey: "savedfont") as? CGFloat {
            return savedFont
        } else {
            return 13.0
        }
    }()
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("default sdk")) {
                    NavigationLink(destination: SDKList(directoryPath: "\(global_sdkpath)" ,sdk: $sdk)) {
                        Text(sdk)
                    }
                }
                Section(header: Text("Advanced")) {
                    NavigationLink(destination: FontSettingsBundleMain()) {
                        Label("Code Editor", systemImage: "doc.plaintext.fill")
                    }
                    NavigationLink(destination: AuthorSettings()) {
                        Label("Author", systemImage: "person.fill")
                    }
                    NavigationLink(destination: Cleaner()) {
                        Label("Cleaner", systemImage: "trash.fill")
                    }
                }
                Section(header: Text("Additional Tools")) {
                    NavigationLink(destination: SDKDownload()) {
                        Label("SDK Hub", systemImage: "arrow.down")
                    }
                    NavigationLink(destination: SFSymbolView()) {
                    Label("SFSymbols", systemImage: "square.grid.3x3.fill")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct textset: View {
    @Binding var bsl: Bool
    @Binding var fname: String
    @Binding var fontstate: CGFloat
    var body: some View {
        List {
            Section(header: Text("Font")) {
                FontPickerView(fname: $fname)
                Stepper("Font Size: \(String(Int(fontstate)))", value: $fontstate, in: 0...20)
                .onChange(of: fontstate) { _ in
                    save()
                }
            }
            Section(header: Text("Appearance")) {
                Toggle("Seperation Layer", isOn: $bsl)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Code Editor")
        .navigationBarTitleDisplayMode(.inline)
    }
    func save() {
        UserDefaults.standard.set(fontstate, forKey: "savedfont")
    }
}

struct FontPickerView: View {
    @State private var selectedFontIndex = 0
    @Binding var fname: String
    let codeEditorFonts: [String] = guif()
    var body: some View {
        VStack {
            Picker(selection: $fname, label: Text("Font")) {
                Group {
                    ForEach(codeEditorFonts, id: \.self) { fontName in
                        Text(fontName)
                            .font(.custom(fontName, size: 16))
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .labelsHidden()
            .clipped()
        }
    }
}

struct AuthorSettings: View {
    @AppStorage("Author") var author: String = "Anonym"
    var body: some View {
        List {
            TextField("Your Name", text: $author)
        }
        .navigationTitle("Author")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct Cleaner: View {
    var body: some View {
       List {
           Button(action: {
               clean(1)
           }) {
               Label("Clean ModuleCache", systemImage: "trash.fill")
           }
           Button(action: {
               clean(2)
           }) {
               Label("Clean Temporary Data", systemImage: "trash.fill")
           }
       }
       .navigationTitle("Cleaner")
       .navigationBarTitleDisplayMode(.inline)
    }
    private func clean(_ arg: Int) {
        DispatchQueue.global(qos: .utility).async {
            ShowAlert(UIAlertController(title: "Cleaning", message: "", preferredStyle: .alert))
                let path: String = {
                    switch(arg) {
                        case 1:
                            return "\(global_documents)/../.cache"
                        case 2:
                            return "\(global_documents)/../tmp"
                        default:
                            return "\(global_documents)/../.cache"
                    }
                }()
                if FileManager.default.fileExists(atPath: path) {
                    do {
                        try adv_rm( atPath: path)
                    } catch {
                    }
                }
            DismissAlert()
        }
    }
}
