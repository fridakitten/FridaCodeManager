 /* 
 StatsView.swift 

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

struct StatsView: View {
    @State private var stats: [(size: Double, count: Int, color: Color, language: String)] = []
    @State private var totalSize: Double = 0.0
    @State private var graph: UUID = UUID()

    var body: some View {
        NavigationView {
            List {
                if totalSize != 0.0 {
                    Section(header: Text("Chart")) {
                        HStack {
                            Spacer()
                            NestedCircleProgressView(stats: stats, totalSize: totalSize)
                                .id(graph)
                            Spacer()
                        }
                    }
                    Section(header: Text("Information")) {
                        ForEach(stats.filter { $0.count > 0 }, id: \.language) { stat in
                            StatsBox(stat: stat, totalSize: totalSize)
                        }
                    }
                } else {
                    Text("No Projects found")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                updateFileSizes()
                graph = UUID()
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func updateFileSizes() {
        let fileExtensions: [(String, Color, String)] = [
            ("swift", .red, "Swift"),
            ("c", .blue, "C"),
            ("cpp", .green, "C++"),
            ("m", .orange, "Objective-C"),
            ("mm", .yellow, "Objective-C++")
        ]

        stats = fileExtensions.map { ext, color, lang in
            let result = calculateFileSizeAndCount(path: global_documents, fileExtension: ext)
            return (result.size, result.count, color, lang)
        }
        
        totalSize = stats.reduce(0) { $0 + $1.size }
    }

    func calculateFileSizeAndCount(path: String, fileExtension: String) -> (size: Double, count: Int) {
        var totalSizeKB: Double = 0.0
        var fileCount: Int = 0
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: path)

        while let file = enumerator?.nextObject() as? String {
            if !file.contains("Frameworks") && !file.contains("frameworks") && file.hasSuffix(fileExtension) {
                let filePath = (path as NSString).appendingPathComponent(file)
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileSize = attributes[FileAttributeKey.size] as? Double {
                        totalSizeKB += fileSize / 1024  // Convert bytes to kilobytes
                        fileCount += 1
                    }
                } catch {
                    print("Error reading file attributes for \(filePath): \(error)")
                }
            }
        }
        return (totalSizeKB, fileCount)
    }
}

struct NestedCircleProgressView: View {
    let stats: [(size: Double, count: Int, color: Color, language: String)]
    let totalSize: Double

    var body: some View {
        ZStack {
            ForEach(0..<stats.count) { index in
                Circle()
                    .trim(
                        from: index == 0 ? 0.0 : CGFloat(stats[0..<index].map { $0.size }.reduce(0, +) / totalSize),
                        to: CGFloat(stats[0...index].map { $0.size }.reduce(0, +) / totalSize)
                    )
                    .stroke(stats[index].color, lineWidth: 20)
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
    }
}

struct StatsBox: View {
    let stat: (size: Double, count: Int, color: Color, language: String)
    let totalSize: Double

    var body: some View {
        HStack {
            Rectangle()
                .foregroundColor(stat.color)
                .cornerRadius(360)
                .frame(width: 20, height: 20)
            Text(stat.language)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(String(format: "%.2f", stat.size / totalSize * 100))% • \(String(format: "%.2f", stat.size)) KB")
                    .font(.system(size: 12, weight: .semibold))
                Text("Files: \(stat.count) • Avg size: \(String(format: "%.2f", stat.size / Double(stat.count))) KB")
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}