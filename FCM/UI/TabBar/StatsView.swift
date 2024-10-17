import SwiftUI

struct StatsView: View {
    @State private var stats: [(size: Double, count: Int, color: Color, language: String)] = []
    @State private var totalSize: Double = 0.0
    @State private var isLoading: Bool = true

    var body: some View {
        NavigationView {
            List {
                if isLoading {
                    Text("Loading ...")
                } else if totalSize != 0.0 {
                    Section(header: Text("Chart")) {
                        HStack {
                            Spacer()
                            NestedCircleProgressView(stats: stats, totalSize: totalSize)
                            Spacer()
                        }
                    }
                    Section(header: Text("Information")) {
                        ForEach(stats.filter { $0.count > 0 }, id: \.language) { stat in
                            StatsBox(stat: stat, totalSize: totalSize)
                        }
                    }
                } else {
                    Text("No files found.")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                updateFileSizes()
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
        DispatchQueue.global(qos: .userInitiated).async {
            var results: [(size: Double, count: Int, color: Color, language: String)] = []
            var totalSizeKB: Double = 0.0
            
            let group = DispatchGroup()
            
            for (ext, color, lang) in fileExtensions {
                group.enter()
                DispatchQueue.global(qos: .utility).async {
                    let result = calculateFileSizeAndCount(path: global_documents, fileExtension: ext)
                    DispatchQueue.main.async {
                        results.append((result.size, result.count, color, lang))
                        totalSizeKB += result.size
                        group.leave()
                    }
                }
            }

            group.wait()

            DispatchQueue.main.async {
                self.stats = results
                self.totalSize = totalSizeKB
                self.isLoading = false
            }
        }
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
                        totalSizeKB += fileSize / 1024
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
            ForEach(0..<stats.count, id: \.self) { index in
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
                Text("Files: \(stat.count) • Avg size: \(stat.count > 0 ? String(format: "%.2f", stat.size / Double(stat.count)) : "0.00") KB")
                    .font(.system(size: 12, weight: .regular))
            }
        }
    }
}