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
    @State var hello: UUID = UUID()
    init() {
// Create a new instance of UINavigationBarAppearance
let navigationBarAppearance = UINavigationBarAppearance()

// Set background color
navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.9) // Adjust alpha as needed

// Set title text attributes
let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label] // Using label color
navigationBarAppearance.titleTextAttributes = titleAttributes

// Set button styles
let buttonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Set button color to white
navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = buttonAttributes

let backItemAppearance = UIBarButtonItemAppearance()
backItemAppearance.normal.titleTextAttributes = [.foregroundColor : UIColor.label] // fix text color
navigationBarAppearance.backButtonAppearance = backItemAppearance

// Apply the appearance to the navigation bar
UINavigationBar.appearance().standardAppearance = navigationBarAppearance
UINavigationBar.appearance().compactAppearance = navigationBarAppearance
UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
    }
    var body: some Scene {
        WindowGroup {
            ContentView(hello: $hello)
                .onOpenURL { url in
                    handleSprojFile(url: url)
                }
        }
    }
    func handleSprojFile(url: URL) {
        do {
            // Get the Documents directory URL
            let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

            // Create a destination URL in the Documents directory with the new name
            let targetURL = documentsURL.appendingPathComponent("target.sproj")

            // Copy the file to the destination URL
            try FileManager.default.copyItem(at: url, to: targetURL)

            // Example: Read content from the copied file
            let copiedFileContent = try String(contentsOf: targetURL)
            print("Copied File Content: \(copiedFileContent)")

        } catch {
            print("Error handling .sproj file: \(error.localizedDescription)")
        }
        importProj()
        hello = UUID()
    }
}