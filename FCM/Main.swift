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

//global environment
let jbroot: String = {
    let preroot: String = String(cString: libroot_dyn_get_jbroot_prefix())
    if !FileManager.default.fileExists(atPath: preroot) {
        if let altroot = altroot(inPath: "/var/containers/Bundle/Application")?.path {
            return altroot
        }
    }
    return preroot
}()
let global_documents: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
let global_sdkpath: String = "\(global_documents)/../.sdk"
let global_version: String = "v1.5"

@main
struct MyApp: App {
    @State var hello: UUID = UUID()
    init() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = UIColor.systemBackground
        let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        navigationBarAppearance.titleTextAttributes = titleAttributes
        let buttonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes
        let backItemAppearance = UIBarButtonItemAppearance()
        backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.label]
        navigationBarAppearance.backButtonAppearance = backItemAppearance
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    var body: some Scene {
        WindowGroup {
            ContentView(hello: $hello)
                .onOpenURL { url in
                        importProj(target: url.path)
                        hello = UUID()
                }
        }
    }
}
