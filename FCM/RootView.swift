 /*
 RootView.swift

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

struct RootView: View {
    @State private var project_list_id: UUID = UUID()

    var body: some View {
        TabView {
            Home(hellnah: $project_list_id)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            ProjectView(hello: $project_list_id)
                .tabItem {
                    Label("Projects", systemImage: "folder")
                }
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
            Settings()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.primary)
        .onOpenURL { url in
            importProj(target: url.path)
            project_list_id = UUID()
        }
    }
}
