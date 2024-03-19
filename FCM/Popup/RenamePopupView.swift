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
    
//
//  Created by Artem Novichkov on 20.05.2021.
//

import SwiftUI
import Foundation

struct RenamePopupView: View {
    
    @State var new: String = ""
    @Binding var isPresented: Bool
    @Binding var old: String
    @Binding var directoryPath: String

    var body: some View {
     ZStack {
        /*FluidGradient(blobs: [.orange, .primary, .yellow],
                      highlights: [.orange, .primary, .yellow],
                      speed: 1.0,
                      blur: 0.75)
          .ignoresSafeArea()
          .frame(height: 220)
          .background(.quaternary)*/
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Rename")
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
            TextField("Filename", text: $new)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
                .onAppear {
                    new = old
                }
            HStack {
                Spacer()
                Button(action: {
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