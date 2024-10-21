 /*
 UIText.swift

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

struct CodeEditorView: View {
    @AppStorage("fontname") var fname: String = "Menlo"
    @AppStorage("bsl") var bsl: Bool = true
    @AppStorage("fbold") var bold: Bool = true
    @AppStorage("defbakcolor") var dbc: Bool = true
    @AppStorage("deftextcolor") var dtc: Bool = true

    @Binding var quar: Bool
    @Binding var filePath: String
    @State var font: CGFloat = {
        if let savedFont = UserDefaults.standard.value(forKey: "savedfont") as? CGFloat {
            return savedFont
        } else {
            return 13.0
        }
    }()
    @State var code: String = " "
    @State var save: Bool = true
    @State var opened: Bool = false
    init(quar: Binding<Bool>,filePath: Binding<String>) {
        _quar = quar
        _filePath = filePath
        UIInit(type: 1)
    }

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if dbc {
                        Color(UIColor.systemGray6)
                            .ignoresSafeArea()
                    } else {
                        loadColor("C7")
                            .ignoresSafeArea()
                    }
                    HighlightedTextEditor(text: $code, highlightRules: grule(gsuffix(from: filePath)))
                        .introspect { editor in
                            editor.textView.font = UIFont(name: "\(fname)\(bold ? "-Bold" : "")", size: font)
                            editor.textView.backgroundColor = .clear
                            editor.textView.tintColor = UIColor(Color.primary)
                            editor.textView.keyboardType = .asciiCapable
                            editor.textView.autocorrectionType = .no
                            editor.textView.autocapitalizationType = .none
                            editor.textView.textContentType = .none
                            editor.textView.smartQuotesType = .no
                            editor.textView.smartDashesType = .no
                            editor.textView.smartInsertDeleteType = .no
                            editor.textView.layoutManager.allowsNonContiguousLayout = false
                            editor.textView.layer.shouldRasterize = true
                            editor.textView.layer.rasterizationScale = UIScreen.main.scale
                            if bsl {
                                editor.textView.layer.shadowColor = UIColor.black.cgColor
                                editor.textView.layer.shadowRadius = 1
                                editor.textView.layer.shadowOpacity = 0.2
                                editor.textView.layer.shadowOffset = CGSize(width: 0, height: 1)
                            }
                    }
                }
                .onAppear {
                    loadCode()
                }
            }
            .navigationBarItems(leading:
                Button("Close") {
                    UIInit(type: 0)
                    quar = false
                }
                .accentColor(.primary)
            )
            .navigationBarItems(trailing:
                Button("Save") {
                    saveCode()
                    hideKeyboard()
                    save = true
                }
                .disabled(save)
                .accentColor(.primary)
            )
            .navigationTitle(findFilename())
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: code) { _ in
            if opened == true {
                save = false
            } else {
                opened = true
            }
        }
    }

    private func loadCode() -> Void {
        do {
            code = load(filePath)
        }
    }

    private func saveCode() -> Void {
        do {
            try code.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("something went wrong :(")
        }
    }

    private func findFilename() -> String {
        if let encodedFilePath = filePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: encodedFilePath) {
            let lastPathComponent = url.lastPathComponent
            let name = lastPathComponent.removingPercentEncoding ?? lastPathComponent
            return name
        }
        return "Untitled"
    }

    private func hideKeyboard() -> Void {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
