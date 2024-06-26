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
 */ 
    
import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct Home: View {
    @State var fileimporter: Bool = false
    @State var showProj: Bool = false
    @Binding var SDK: String
    @State var app: String = ""
    @State var bundleid: String = ""
    @State var about: Bool = false
    @State var hello: UUID = UUID()
    @Binding var hellnah: UUID
    @Environment(\.presentationMode) var presentationMode

	let changeLog: String {
		do {
			String(contentsOfFile: Bundle.main.bundlePath + "/changelog", encoding: .utf8)
		} catch {
			"Unable to read the changelog file: \(error.localizedDescription)"
		}
	}
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Changelog")) {
                    VStack {
                        Spacer().frame(height: 10)
                            ScrollView {
                                Text(changeLog))
                                    .font(.system(size: 11))
                                }
                                Button("See older releases changelog") {
									openURL(URL(string: "https://github.com/fridakitten/FridaCodeManager/releases"))
                                }
                                Spacer()
                            }
                            .frame(height: 200)
                        }
                        Section() {
                            Button(action: {
                                showProj = true
                                hellnah = UUID()
                            }){
                                listItem(label: "Create Project", systemImageName: "plus.rectangle", text: "Create a FCM Project")
                            }
                            Button(action: {
                                $fileimporter.trampolineIfNeeded(to: true)
                            }){
                                listItem(label: "Import Project", systemImageName: "tray.and.arrow.down", text: "Import a Project")
                            }
                        }
                        Button( action: {
                            hello = UUID()
                            about = true
                        }){
                            listItem(label: "About", systemImageName: "person.crop.rectangle", text: "Show informations about this App")
                        }
                        .sheet(isPresented: $about) {
                            Frida(hello: $hello)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .navigationTitle("FridaCodeManager")
                    .navigationBarTitleDisplayMode(.inline)
                    .fileImporter(isPresented: $fileimporter,allowedContentTypes: [.project]) { result in
                    do {
                        let fileURL = try result.get()
                        importProj(target: fileURL.path)
                        hellnah = UUID()
                    } catch {
                        print("Error importing file: \(error.localizedDescription)")
                    }
                }
            }
            .sheet(isPresented: $showProj) {
                BottomPopupView {
                    ProjPopupView(isPresented: $showProj, AppName: $app, BundleID: $bundleid, SDK: $SDK, hellnah: $hellnah)
                }
                .background(BackgroundClearView())
            }
        }

        func listItem(label: String, systemImageName: String, text: String) -> some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(label)
                        .font(.headline)
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Label("", systemImage: systemImageName)
        }
    }

    func handleFileImport(_ fileURL: URL) {
    	do {
        	let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        	let targetURL = documentsURL.appendingPathComponent("target.sproj")

        	try FileManager.default.copyItem(at: fileURL, to: targetURL)

        	// Additional logic after successful import
        	print("File copied successfully to \(targetURL)")
    	} catch {
        	print("Error handling file import: \(error.localizedDescription)")
    	}
  	}
}

extension UTType {
    static var project: UTType {
        UTType(filenameExtension: "sproj")!
    }
    static var all: UTType {
        UTType(filenameExtension: "txt")!
    }
}
