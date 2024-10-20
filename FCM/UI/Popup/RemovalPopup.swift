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

struct RemovalPopup: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var path: String
    var body: some View {
     ZStack {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Remove \"\(name)\"?")
                    .font(.system(size: 20, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
            }
            Spacer().frame(height:30)
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
                    removeFile_trigger()
                }, label: {
                    Text("Confirm")
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

    private func removeFile_trigger() -> Void {
        haptfeedback(1)
        _ = rm("\(path)")
        isPresented = false
    }
}
