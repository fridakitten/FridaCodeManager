 /* 
 ProjPopupView.swift 

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

struct ProjPopupView: View {
    @Binding var isPresented: Bool
    @Binding var AppName: String
    @Binding var BundleID: String
    @Binding var SDK: String
    @Binding var hellnah: UUID
    @State private var type = 1
    var body: some View {
     ZStack {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Create Project")
                    .font(.system(size: 25, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    isPresented = false
                }, label: {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.06))
                        .cornerRadius(16)
                        .foregroundColor(.primary)
                })
            }
            TextField("Application Name", text: $AppName)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            TextField("Bundle Identifier", text: $BundleID)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            HStack {
                HStack {
                Spacer().frame(width: 10)
                Text("Scheme")
                    .foregroundColor(.primary)
                Spacer()
                VStack {
                Picker("" ,selection: $type) {
                    Text("Swift App").tag(1)
                    Text("ObjC App").tag(2)
                    Text("Swift/ObjC App").tag(3)
            }
            .pickerStyle(MenuPickerStyle())
                }
                Spacer()
                }
                .frame(height: 36)
                .background(Color(.systemBackground).opacity(0.5))
                .foregroundColor(.primary)
                .accentColor(.secondary)
                .cornerRadius(10)
                Spacer().frame(width: 10)
                Button(action: {
                    if AppName != "", BundleID != "", !FileManager.default.fileExists(atPath: "\(global_documents)/\(AppName)") {
                        haptfeedback(1)
                        isPresented = false
                        MakeApplicationProject(AppName, BundleID,SDK: SDK, type: type)
                        AppName = ""
                        BundleID = ""
                        hellnah = UUID()
                        return
                    }
                    haptfeedback(2)
                }, label: {
                    Text("Submit")
                })
                .frame(width: 80, height: 36)
                .background(Color(.systemBackground).opacity(0.5))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
        .padding()
    }
  }
}
