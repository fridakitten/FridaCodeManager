 /* 
 RenamePopupView.swift 

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

struct RenamePopupView: View {
    
    @State var new: String = ""
    @Binding var isPresented: Bool
    @Binding var old: String
    @Binding var directoryPath: String

    var body: some View {
     ZStack {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Rename \"\(old)\"?")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
            }
            TextField("Filename", text: $new)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
                .onAppear {
                    new = old
                }
                .disableAutocorrection(true)
                .autocapitalization(.none)
            HStack {
                Button(action: {
                    isPresented = false
                }, label: {
                    Text("Cancel")
                })
                .frame(width: 80, height: 36)
                .background(Color(.systemBackground).opacity(0.5))
                .foregroundColor(.primary)
                .cornerRadius(10)
                Spacer()
                Button(action: {
                    haptfeedback(1)
                    let oldpath = "\(directoryPath)/\(old)"
                    try? renameFile(atPath: oldpath, to: new)
                    isPresented = false
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
