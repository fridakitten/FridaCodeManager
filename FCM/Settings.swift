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
            return 15.0
        }
    }()
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("default sdk")) {
                    NavigationLink(destination: SDKList(directoryPath: "\(global_sdkpath)" ,sdk: $sdk)) {
                        Text(sdk)
                    }
                    NavigationLink(destination: SDKDownload()) {
                        Text("SDK Hub")
                    }
                }
                Section(header: Text("Advanced")) {
                    NavigationLink(destination: textset(bsl: $bsl, fname: $fname,fontstate: $fontstate)) {
                        Text("Code Editor")
                        }
                    NavigationLink(destination: DebugSettings()) {
                        Text("Debug")
                    }
                }
                Section(header: Text("Additional Tools")) {
                    NavigationLink(destination: SFSymbolView()) {
                    Text("SFSymbols")
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DebugSettings: View {
    @AppStorage("debug") var show: Bool = false
    var body: some View {
        List {
            Toggle("Debug Log",isOn: $show)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Debug")
        .navigationBarTitleDisplayMode(.inline)
    }
}
