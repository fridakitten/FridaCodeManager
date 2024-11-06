 /*
 UICreditsView.swift

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

struct CreditsView: View {
    private let credits = [
        ("SeanIsNotAConstant", "Main Developer", "https://github.com/fridakitten.png"),
        ("AppInstaller iOS", "Developer", "https://github.com/AppInstalleriOSGH.png"),
        ("RoothideDev", "Contributor", "https://github.com/roothide.png"),
        ("Snoolie", "Contributor", "https://github.com/0xilis.png"),
        ("HAHALOSAH", "Contributor", "https://github.com/HAHALOSAH.png"),
        ("darwinx64", "Contributor", "https://github.com/darwinx64.png"),
        ("Manuel Chakravarty", "Contributor", "https://github.com/mchakravarty.png"),
        ("Ayame Yumemi", "Icon Designer", "https://github.com/ayayame09.png"),
        ("meighler", "Licensor", "https://github.com/meighler.png")
    ]

    private let sideCredits = [
        ("Opa334", "Trollstore Helper", "https://github.com/opa334.png"),
        ("Theos", "SDK", "https://github.com/theos.png")
    ]

    private let others = [
        ("Chariz", "Repo Host", "https://github.com/chariz.png")
    ]

    var body: some View {
        ForEach([
            ("Credits", "heart", credits),
            ("Side Credits", "star", sideCredits),
            ("Others", "sparkles", others)
        ], id: \.0) { sectionTitle, sectionImage, sectionCredits in
            Section {
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
            } header: {
                Label(sectionTitle, systemImage: sectionImage)
            }
        }
    }
}
