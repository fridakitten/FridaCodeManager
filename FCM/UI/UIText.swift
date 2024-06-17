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
        if #available(iOS 15.0, *) { 
            let navigationBarAppearance = UINavigationBarAppearance()

navigationBarAppearance.configureWithDefaultBackground() 
    UINavigationBar.appearance().standardAppearance = navigationBarAppearance 
    UINavigationBar.appearance().compactAppearance = navigationBarAppearance 
    UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
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
// Create a new instance of UINavigationBarAppearance
let navigationBarAppearance = UINavigationBarAppearance()

// Set background color
navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9) // Adjust alpha as needed

// Set title text attributes
let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label] // Using label color
navigationBarAppearance.titleTextAttributes = titleAttributes

// Set button styles
let buttonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Set button color to white
navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes

let backItemAppearance = UIBarButtonItemAppearance()
backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.label] // fix text color
navigationBarAppearance.backButtonAppearance = backItemAppearance

// Apply the appearance to the navigation bar
UINavigationBar.appearance().standardAppearance = navigationBarAppearance
UINavigationBar.appearance().compactAppearance = navigationBarAppearance
UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
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
    private func loadCode() {
        do {
            code = try! String(contentsOfFile: filePath)
        }
    }
    private func saveCode() {
        do {
            try! code.write(toFile: filePath, atomically: true, encoding: .utf8)
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
    func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}