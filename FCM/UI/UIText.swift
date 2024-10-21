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
                CodeEditorGreat(text: $code, font: font, suffix: gsuffix(from: filePath))
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
