//
// Layout.swift
//
// Created by SeanIsNotAConstant on 03.09.24
//
 
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct Layout: Codable, Identifiable, Equatable {
    var id = UUID() // Unique identifier for the layout
    var example: Int?
}

struct LayoutST: View {
    //layout values
    /*@Binding*/@State var example: Int = 0

    //necessary
    @AppStorage("layoutName") var layoutName: String = ""
    @State private var savedLayouts: [String: Layout] = [:]
    @State private var selectedLayout: Layout?
    var body: some View {
        ZStack {
                VStack {
                    List {
                        Section(header: Text("Save Layout")) {
                            HStack {
                                TextField("  Layout Name", text: $layoutName)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: 35)
                                
                                Button("Save") {
                                    saveLayout()
                                }
                                .frame(width: 60, height: 33)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(5)
                            }
                            .frame(height: 50)
                        }
                            Section(header: Text("Load Layout")) {
                            ForEach(savedLayouts.sorted(by: { $0.key < $1.key }), id: \.key) { key, layout in
                                Button(action: {
                                    applyLayout(layout)
                                }) {
                                    Text(key)
                                        .foregroundColor(.primary)
                                }
                                .contextMenu {
                                    Section {
                                        Button(role: .destructive) {
                                            deleteLayout(layout)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .onDelete { indexSet in
                                deleteLayouts(at: indexSet)
                            }
                        }
                    }
                    .onAppear(perform: loadlayoutlist)
                }
            }
            .navigationTitle("Layouts")
            .navigationBarTitleDisplayMode(.inline)
    }
    /*private func renameLayout(_ layout: Layout) {
        let alertController = UIAlertController(title: "Rename Layout", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Enter new name"
            textField.text = layout.layoutname // Pre-fill the current name
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let renameAction = UIAlertAction(title: "Rename", style: .default) { [self, alertController] _ in
            guard let newName = alertController.textFields?.first?.text else { return }
            self.updateLayoutName(layout, newName: newName)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(renameAction)
        
        if let viewController = UIApplication.shared.windows.first?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    private func updateLayoutName(_ layout: Layout, newName: String) {
        if let existingLayout = savedLayouts.removeValue(forKey: layout.layoutname ?? "") {
            var updatedLayout = layout
            updatedLayout.layoutname = newName
            savedLayouts[newName] = updatedLayout
            saveSavedLayouts()
        }
    }*/
    private func saveSavedLayouts() {
        // Save the updated savedLayouts dictionary
        guard let saveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("savedLayouts.json") else {
            print("Error accessing save file.")
            return
        }
        
        do {
            let saveData = try JSONEncoder().encode(savedLayouts)
            try saveData.write(to: saveURL)
            print("Saved layouts updated successfully.")
        } catch {
            print("Error updating saved layouts: \(error)")
        }
    }
    /*func loadExportedLayoutFile() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to access the documents directory.")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("exportedLayout.json")
        
        do {
            let layoutData = try Data(contentsOf: fileURL)
            let importedLayout = try JSONDecoder().decode(Layout.self, from: layoutData)
            
            // Handle the imported layout
            handleImportedLayout(importedLayout)
            
        } catch {
            print("Error importing layout: \(error)")
        }
    }*/
    /*private func exportLayout(_ layout: Layout) {
        do {
            let layoutData = try JSONEncoder().encode(layout)
            let temporaryURL = FileManager.default.temporaryDirectory.appendingPathComponent("exportedLayout.json")
            try layoutData.write(to: temporaryURL)
            
            let activityViewController = UIActivityViewController(activityItems: [temporaryURL], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        } catch {
            print("Error exporting layout: \(error)")
        }
    }*/
    private func saveLayout() {
        //convcolor()
        let layout = Layout(example: example)
        if let layoutData = try? JSONEncoder().encode(layout) {
            savedLayouts[layoutName] = try? JSONDecoder().decode(Layout.self, from: layoutData)
        }
        
        //UserDefaults.standard.set(layout.symbols, forKey: "Symbols")
        saveLayoutsToFile()
        layoutName = ""
    }
    
    private func loadLayout(_ layout: Layout) {
        example = layout.example ?? 0
    }
    /*func importLayout(layout: Layout) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(layout)
            return jsonData
        } catch {
            print("Error encoding layout: \(error)")
            return nil
        }
    }*/
    private func loadlayoutlist() {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectoryURL.appendingPathComponent("savedLayouts.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            savedLayouts = try JSONDecoder().decode([String: Layout].self, from: data)
        } catch {
            print("Error loading saved layouts: \(error)")
        }
    }
    
    private func saveLayoutsToFile() {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let fileURL = documentsDirectoryURL.appendingPathComponent("savedLayouts.json")
        
        do {
            let data = try JSONEncoder().encode(savedLayouts)
            try data.write(to: fileURL)
        } catch {
            print("Error saving layouts: \(error)")
        }
    }
    func applyLayout(_ layout: Layout) {
            example = layout.example ?? 0
    }
    private func deleteLayouts(at offsets: IndexSet) {
        let indicesToRemove = Array(offsets)
        let layoutKeys = savedLayouts.keys.sorted()
        
        var updatedLayouts: [String: Layout] = [:]
        
        for (index, key) in layoutKeys.enumerated() {
            if !indicesToRemove.contains(index) {
                updatedLayouts[key] = savedLayouts[key]
            }
        }
        
        savedLayouts = updatedLayouts
        saveLayoutsToFile()
    }
    private func deleteLayout(_ layout: Layout) {
        if let key = savedLayouts.first(where: { $0.value == layout })?.key {
            savedLayouts[key] = nil
            saveLayoutsToFile()
        }
    }
}