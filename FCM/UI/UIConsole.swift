 /* 
 UIConsole.swift 

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

struct LogView: View {
    @Binding var LogItems: [String]
    
    var body: some View {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(LogItems.filter { !$0.contains("perform implicit import") && !$0.contains("clang-14: warning: -framework") }.joined(separator: "\n"))")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(4)
                    }
                    .padding(.horizontal)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15)
                }
                .frame(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.height / 2)
        .contextMenu {
            Button("Copy Log") {
                let fullstring: String = "\(LogItems.filter { !$0.contains("perform implicit import") && !$0.contains("clang-14: warning: -framework") }.joined(separator: "\n"))"
                copyToClipboard(text: fullstring, alert: false)
            }
        }
    }
}

func copyToClipboard(text: String, alert: Bool? = true) {
    haptfeedback(1)
    if (alert ?? true) {ShowAlert(UIAlertController(title: "Copied", message: "", preferredStyle: .alert))}
    UIPasteboard.general.string = text
    if (alert ?? true) {DismissAlert()}
}