 /*
 main.swift

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

@main
struct MyApp: App {
    init() {
        UIInit(type: 0)
        UpdateFixer()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

    private func UpdateFixer() -> Void {
        if !UserDefaults.standard.bool(forKey: "ui_update152") {
            resetlayout()
            UserDefaults.standard.set(true, forKey: "ui_update152")
        }
    }
}
