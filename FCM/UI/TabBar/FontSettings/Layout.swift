//
// Layout.swift
//
// Created by SeanIsNotAConstant on 03.09.24
//
 
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct Layout: Codable, Identifiable, Equatable {
    var id = UUID()
    // -> properties
    var font: CGFloat?
    var fontname: String?
    var fontbold: Bool?
    var fontbsl: Bool?
    var dbc: Bool?
    var dtc: Bool?
    // -> color
    var c1: String?
    var c2: String?
    var c3: String?
    var c4: String?
    var c5: String?
    var c6: String?
    var c7: String?
    var c8: String?
}

struct LayoutST: View {
    //layout values
    // -> properties
    @Binding var font: CGFloat
    @Binding var fontname: String
    @Binding var fontbold: Bool
    @Binding var fontbsl: Bool
    @Binding var dbc: Bool
    @Binding var dtc: Bool
    @State var c1: String = ""
    @State var c2: String = ""
    @State var c3: String = ""
    @State var c4: String = ""
    @State var c5: String = ""
    @State var c6: String = ""
    @State var c7: String = ""
    @State var c8: String = ""

    //necessary
    @AppStorage("layoutName") var layoutName: String = ""
    @State private var savedLayouts: [String: Layout] = [:]
    @State private var selectedLayout: Layout?
    // -> color
    @Binding var rc1: Color
    @Binding var rc2: Color
    @Binding var rc3: Color
    @Binding var rc4: Color
    @Binding var rc5: Color
    @Binding var rc6: Color
    @Binding var rc7: Color
    @Binding var rc8: Color
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
                    .onAppear {
                        c1 = colorToRGBString(rc1)
                        c2 = colorToRGBString(rc2)
                        c3 = colorToRGBString(rc3)
                        c4 = colorToRGBString(rc4)
                        c5 = colorToRGBString(rc5)
                        c6 = colorToRGBString(rc6)
                        c7 = colorToRGBString(rc7)
                        c8 = colorToRGBString(rc8)
                    }
                }
            }
            .navigationTitle("Layouts")
            .navigationBarTitleDisplayMode(.inline)
    }
    private func saveSavedLayouts() {
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
    private func saveLayout() {
        let layout = Layout(
            font: font,
            fontname: fontname,
            fontbold: fontbold,
            fontbsl: fontbsl,
            dbc: dbc,
            dtc: dtc,
            c1: c1,
            c2: c2,
            c3: c3,
            c4: c4,
            c5: c5,
            c6: c6,
            c7: c7,
            c8: c8
        )
        if let layoutData = try? JSONEncoder().encode(layout) {
            savedLayouts[layoutName] = try? JSONDecoder().decode(Layout.self, from: layoutData)
        }
        saveLayoutsToFile()
        layoutName = ""
    }
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
        // -> load properties strings
        font = layout.font ?? 13
        fontname = layout.fontname ?? "Menlo"
        fontbold = layout.fontbold ?? false
        fontbsl = layout.fontbsl ?? false
        dbc = layout.dbc ?? true
        dtc = layout.dtc ?? true
        // -> load color strings
        c1 = layout.c1 ?? ""
        c2 = layout.c2 ?? ""
        c3 = layout.c3 ?? ""
        c4 = layout.c4 ?? ""
        c5 = layout.c5 ?? ""
        c6 = layout.c6 ?? ""
        c7 = layout.c7 ?? ""
        c8 = layout.c8 ?? ""
        // -> store color strings into app storage
        saveColor("C1", RGBStringToColor(c1))
        saveColor("C2", RGBStringToColor(c2))
        saveColor("C3", RGBStringToColor(c3))
        saveColor("C4", RGBStringToColor(c4))
        saveColor("C5", RGBStringToColor(c5))
        saveColor("C6", RGBStringToColor(c6))
        saveColor("C7", RGBStringToColor(c7))
        saveColor("C8", RGBStringToColor(c8))
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