/* 
 FontBundleMain.swift 

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

struct FontSettingsBundleMain: View {
    //old texset
    @AppStorage("fontname") var fname: String = "Menlo"
    @AppStorage("bsl") var bsl: Bool = true
    @AppStorage("fbold") var bold: Bool = false

    //color
    @State private var color1: Color = Color.red
    @State private var color2: Color = Color.red
    @State private var color3: Color = Color.red
    @State private var color4: Color = Color.red
    @State private var color5: Color = Color.red
    @State private var color6: Color = Color.red

    @State var font: CGFloat = 0.0

    @State private var code: String = """
struct ContentView: View {
    var body: some View {
        Text("Hewwo :3")
    }
}

// nya mrrrp
"""

    @State private var identifier: UUID = UUID()
    var body: some View {
            List {
                CodeEditorPreview(text: $code, font: $font, suffix: "swift")
                    .frame(height: 120)
                    .id(identifier)
                Section("Color") {
                    HStack {
                        ColorPicker("", selection: $color1)
                            .onChange(of: color1) { _ in
                                 saveallcolor()
                                 identifier = UUID()
                             }
                        ColorPicker("", selection: $color2)
                            .onChange(of: color2) { _ in
                                 saveallcolor()
                                 identifier = UUID()
                             }
                        ColorPicker("", selection: $color3)
                            .onChange(of: color3) { _ in
                                 saveallcolor()
                                 identifier = UUID()
                             }
                        ColorPicker("", selection: $color4)
                            .onChange(of: color4) { _ in
                                 saveallcolor()
                                 identifier = UUID()
                             }
                        ColorPicker("", selection: $color5)
                            .onChange(of: color5) { _ in
                                 saveallcolor()
                                 identifier = UUID()
                             }
                        ColorPicker("", selection: $color6)
                            .onChange(of: color6) { _ in
                                 saveallcolor()
                                 identifier = UUID()
                             }
                    }
                    Toggle("Text Seperation Layer", isOn: $bsl)
                        .onChange(of: bsl) { _ in
                            identifier = UUID()
                         }
                }
                Section(header: Text("Properties")) {
                    FontPickerView(fname: $fname)
                        .onChange(of: fname) { _ in
                            identifier = UUID()
                         }
                    Stepper("Font Size: \(String(Int(font)))", value: $font, in: 0...20)
                        .onChange(of: font) { _ in
                            UserDefaults.standard.set(font, forKey: "savedfont")
                            identifier = UUID()
                         }
                    Toggle("Bold", isOn: $bold)
                        .onChange(of: bold) { _ in
                            identifier = UUID()
                        }
                }
                Section {
                    NavigationLink(destination: LayoutST()) {
                            Text("Layouts")
                        }
                    Button("Reset") {
                        color1 = Color(UIColor(red: 1.0, green: 0.2, blue: 0.6, alpha: 1.0))
                        color2 = Color(UIColor(red: 0, green: 0.6, blue: 0.498, alpha: 1.0))
                        color3 = Color(UIColor(red: 0.7137, green: 0, blue: 1, alpha: 1.0))
                        color4 = Color(UIColor(red: 0.7569, green: 0.2039, blue: 0.3882, alpha: 1.0))
                        color4 = Color(UIColor(red: 0.7569, green: 0.2039, blue: 0.3882, alpha: 1.0))
                        color5 = Color(UIColor(red: 0, green: 0.4824, blue: 0.9098, alpha: 1.0))
                        color6 = Color(UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
                        saveallcolor()
                        font = 13
                        UserDefaults.standard.set(font, forKey: "savedfont")
                        bsl = true
                        bold = false
                        fname = "Menlo"
                        identifier = UUID()
                    }
                }
            }
            .navigationTitle("Code Editor")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                (color1, color2, color3, color4, color5, color6) = (loadColor("C1"), loadColor("C2"), loadColor("C3"), loadColor("C4"), loadColor("C5"), loadColor("C6"))
                font = {
                    if let savedFont = UserDefaults.standard.value(forKey: "savedfont") as? CGFloat {
                        return savedFont
                    } else {
                         return 13.0
                    }
                }()
            }
    }
    func saveallcolor() {
        saveColor("C1", color1)
        saveColor("C2", color2)
        saveColor("C3", color3)
        saveColor("C4", color4)
        saveColor("C5", color5)
        saveColor("C6", color6)
    }
}