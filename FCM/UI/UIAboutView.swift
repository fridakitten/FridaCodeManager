 /* 
 AboutView.swift 

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

struct Frida: View {
    @Binding var hello: UUID
    
    private let credits = [
        ("SeanIsNotAConstant", "Main Developer", "https://github.com/fridakitten.png"),
        ("AppInstaller iOS", "Compiling Genius", "https://github.com/AppInstalleriOSGH.png"),
        ("Snoolie", "Helping Hand", "https://github.com/0xilis.png"),
        ("HAHALOSAH", "Helping Hand", "https://github.com/HAHALOSAH.png"),
        ("Ayame Yumemi", "Icon Designer", "https://github.com/ayayame09.png"),
        ("meighler", "Licensor", "https://github.com/meighler.png")
    ]

    private let sideCredits = [
        ("Opa334", "Trollstore Helper", "https://github.com/opa334.png"),
        ("Theos", "SDK", "https://github.com/theos.png")
    ]

    private let supporters = [
        ("RoothideDev", "Giving me Power", "https://github.com/roothide.png"),
        ("Speedyfriend67", "Making Projects using FCM", "https://github.com/speedyfriend433.png"),
        ("Burhan Rana", "Making videos about my tools", "https://github.com/burhangee.png")
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("About")) {
                    Text("FridaCodeManager \(global_version)")
                }
                
                ForEach([
                    ("Credits", credits),
                    ("Side Credits", sideCredits),
                    ("Supporters", supporters)
                ], id: \.0) { sectionTitle, sectionCredits in
                    Section(header: Text(sectionTitle)) {
                        ForEach(sectionCredits.indices, id: \.self) { index in
                            HStack {
                                AsyncImageLoaderView(urlString: sectionCredits[index].2, width: 50, height: 50)
                                    .shadow(color: Color.black.opacity(0.5), radius: 2, x: 0, y: 2)
                                Spacer()
                                VStack {
                                    Text(sectionCredits[index].0)
                                        .foregroundColor(.primary)
                                        .font(.system(size: 14, weight: .bold))
                                    Text(sectionCredits[index].1)
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .frame(width: 200)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .id(hello)
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(InsetGroupedListStyle())
        }
    }
}