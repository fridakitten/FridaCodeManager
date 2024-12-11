 /* 
 Home.swift 

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

  ______    _     _         _____        __ _                           ______                    _       _   _
 |  ___|  (_)   | |       /  ___|      / _| |                          |  ___|                  | |     | | (_)
 | |_ _ __ _  __| | __ _  \ `--.  ___ | |_| |___      ____ _ _ __ ___  | |_ ___  _   _ _ __   __| | __ _| |_ _  ___  _ __
 |  _| '__| |/ _` |/ _` |  `--. \/ _ \|  _| __\ \ /\ / / _` | '__/ _ \ |  _/ _ \| | | | '_ \ / _` |/ _` | __| |/ _ \| '_ \
 | | | |  | | (_| | (_| | /\__/ / (_) | | | |_ \ V  V / (_| | | |  __/ | || (_) | |_| | | | | (_| | (_| | |_| | (_) | | | |
 \_| |_|  |_|\__,_|\__,_| \____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___| \_| \___/ \__,_|_| |_|\__,_|\__,_|\__|_|\___/|_| |_|
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */ 
    
import SwiftUI
import UniformTypeIdentifiers

struct Home: View {
    @State private var fileImporter = false
    @State private var showProj = false
    @State private var about = false
    @State private var hello = UUID()
    @Binding var hellnah: UUID
    @Environment(\.presentationMode) private var presentationMode

    @State var AppName: String = ""
    @State var BundleID: String = ""

    #if jailbreak
    @State private var type = 1
    #elseif trollstore || stock
    @State private var type = 2
    #endif

    var body: some View {
        NavigationView {
            List {
                changelogSection
                projectButtonsSection
                aboutButton
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("FridaCodeManager")
            .navigationBarTitleDisplayMode(.inline)
            .fileImporter(isPresented: $fileImporter, allowedContentTypes: [.project], onCompletion: handleFileImport)
            .sheet(isPresented: $showProj) {
                BottomPopupView {
                    POHeader(title: "Create Project")
                    POTextField(title: "Application Name", content: $AppName)
                    POTextField(title: "Bundle Identifier", content: $BundleID)
                    POPicker(function: createProject_trigger, title: "Scheme", arrays: [PickerArrays(title: "App", items: [PickerItems(id: 1, name: "Swift"), PickerItems(id: 2, name: "ObjC"), PickerItems(id: 3, name: "Swift/ObjC"), PickerItems(id: 5, name: "Swift/C++")]), PickerArrays(title: "Binary", items: [PickerItems(id: 4, name: "C")])], type: $type)
                }
                .background(BackgroundClearView())
                .edgesIgnoringSafeArea([.bottom])
            }
        }
        .navigationViewStyle(.stack)
    }

    private func createProject_trigger() -> Void {
        if AppName != "", BundleID != "" {
            haptfeedback(1)
            showProj = false
            _ = MakeApplicationProject(AppName, BundleID, type: type)
            (AppName, BundleID, hellnah) = ("", "", UUID())
        } else {
            haptfeedback(2)
        }
    }

    private var changelogSection: some View {
        Section(header: Text("Changelog")) {
            VStack {
                Spacer().frame(height: 10)
                ScrollView {
                    Text(changelog)
                        .font(.system(size: 11))
                }
                Spacer()
            }
            .frame(height: 200)
        }
    }

    private var projectButtonsSection: some View {
        Section {
            Button(action: {
                AppName = ""
                BundleID = ""
                showProj = true
            }) {
                listItem(label: "Create Project", systemImageName: "+", text: "Creates a FCM Project")
            }
            Button(action: {
                fileImporter = true
            }) {
                listItem(label: "Import Project", systemImageName: "↑", text: "Imports a FCM Project")
            }
        }
    }

    private var aboutButton: some View {
        Button(action: {
            hello = UUID()
            about = true
        }) {
            listItem(label: "About", systemImageName: "i", text: "Shows Information about this App")
        }
        .sheet(isPresented: $about) {
            Frida(hello: $hello)
        }
    }

    private func listItem(label: String, systemImageName: String, text: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label).font(.headline)
                Text(text).font(.subheadline).foregroundColor(.gray)
            }
            Spacer()
            ZStack {
                Rectangle()
                    .foregroundColor(.secondary)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .cornerRadius(4)
                Text(systemImageName)
                    .foregroundColor(Color(.systemBackground))
                    .frame(width: 20, height: 20)
                    .font(Font.custom("Menlo", size: 16).bold())
            }
        }
    }

    private func handleFileImport(result: Result<URL, Error>) -> Void {
        switch result {
        case .success(let fileURL):
            importProj(target: fileURL.path)
            hellnah = UUID()
        case .failure(let error):
            print("Error importing file: \(error.localizedDescription)")
        }
    }
}

extension UTType {
    static var project: UTType { UTType(filenameExtension: "sproj")! }
}
