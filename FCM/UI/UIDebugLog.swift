/* 
 UIDebugLog.swift 

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

struct Debug: View {
    @State private var position: CGSize = .zero
    @State private var startPosition: CGSize = .zero
    var body: some View {
        LogViewDebug()
            .shadow(color: Color.primary.opacity(1), radius: 4, x: 0, y: 0)
            .offset(x: position.width, y: position.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        position = CGSize(
                            width: startPosition.width + value.translation.width,
                            height: startPosition.height + value.translation.height
                        )
                    }
                    .onEnded { value in
                        startPosition = position
                    }
            )
    }
}

struct LogViewDebug: View {
    @State var LogItems: [String.SubSequence] = [""] 
    @AppStorage("cmp") var cmp: Bool = true
    var body: some View {
        Group {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            Text("\(LogItems.filter { !$0.contains("perform implicit import") }.joined(separator: "\n"))")
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(2)
                        .flipped()
                    }
                    .padding(.horizontal)
                    .flipped()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                }
                .frame(width: 200,height: 300)
        }
        .onDisappear {
            LogItems = [""]
        }
        Spacer().frame(height: 0)
        .onAppear {
            _ = LogStream($LogItems)
        }
    }
}