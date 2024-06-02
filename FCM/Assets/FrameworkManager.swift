 /* 
FrameworkManager.swift 

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

struct Packages: View {
    @State var pck: String = ""
    @State var puuid: UUID = UUID()
    @State var inputtext: String = ""
    @State var showAlert: Bool = false
    @State var showGit: Bool = false
    var body: some View {
        VStack {
            PKG(directoryPath: "\(global_documents)/frameworks")
                .id(puuid)
        }
        .onChange( of: showGit) { _ in
            if showGit == true {
                DispatchQueue.global(qos: .utility).async {
                    ShowAlert(UIAlertController(title: "Adding Framework...", message: "", preferredStyle: .alert))
                    let pckgg = "\(global_documents)/frameworks"
                    cfolder(atPath: pckgg)
                    pck = pckgg
                    print("github url: \(inputtext)")
                    print("output: \(pck)")
                    shell("mkdir -p \(pck)/downloads")
                    shell("cd \(pck)/downloads && git clone \(inputtext)")
                    let temp_frame = (getSingleFolderName(in: "\(pck)/downloads") ?? "Not found")
                    print("framework name: \(temp_frame)")
                    shell("mv \(pck)/downloads/\(temp_frame)/Sources \(pck)/\(temp_frame)")
                    shell("cd \(pck) && rm -rf ./downloads")
                    inputtext = ""
                    DismissAlert()
                    showGit = false
                    puuid = UUID()
                }
            }
        }
        .navigationTitle("Packages")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {
            showAlert = true
        }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showAlert) {
             BottomPopupView {
                 NamePopupView(isPresented: $showAlert, inputtext: $inputtext, showGit: $showGit, pck: $pck)
             }
             .background(BackgroundClearView())
         }
    }
    func getSingleFolderName(in directoryPath: String) -> String? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: directoryPath)
            guard contents.count == 1, let folderName = contents.first else {
                return nil // No or multiple folders found
            }
            let folderPath = (directoryPath as NSString).appendingPathComponent(folderName)
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: folderPath, isDirectory: &isDirectory), isDirectory.boolValue else {
                return nil // The single item is not a folder
            }
            return folderName
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
        func pckg() {
            let pckgg = "\(global_documents)/frameworks"
            cfolder(atPath: pckgg)
            puuid = UUID()
        }
    }
}
