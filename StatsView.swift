import SwiftUI

struct StatsView: View {
    @State private var docdir: String = docsDir()
    @State private var totalSize: Double = 0.0
    @State private var swiftSize: Double = 0.0
    @State private var cSize: Double = 0.0
    @State private var cppSize: Double = 0.0
    @State private var objCSize: Double = 0.0
    @State private var objCppSize: Double = 0.0
    @State private var graph: UUID = UUID()
    var body: some View {
        NavigationView {
            List {
              if totalSize != 0.0 {
              Section(header: Text("chart")) {
                HStack {
                    Spacer()
                    NestedCircleProgressView(progressValues: [swiftSize, cSize, cppSize, objCSize, objCppSize], totalSize: totalSize)
                    .id(graph)
                    Spacer()
                }
                }
                Section(header: Text( 
"Information")) {
                statsbox(color: Color.red, language: "Swift", doub: swiftSize, per: cp(value: swiftSize, of: totalSize))
                statsbox(color: Color.blue, language: "C", doub: cSize, per: cp(value: cSize, of: totalSize))
                statsbox(color: Color.green, language: "C++", doub: cppSize, per: cp(value: cppSize, of: totalSize))
                statsbox(color: Color.orange, language: "ObjectiveC", doub: objCSize, per: cp(value: objCSize, of: totalSize))
                statsbox(color: Color.yellow, language: "ObjectiveC++", doub: objCppSize, per: cp(value: objCppSize, of: totalSize))
                }
                } else {
                Text("No Projects found")
                }
            }
            .listStyle(GroupedListStyle())
            .onAppear {
                updateFileSizes()
                graph = UUID()
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    func cp(value: Double, of specificValue: Double) -> Double {
        guard specificValue != 0.0 else {
            return 0.0
        }
    
        let percentage = Double(value) / Double(specificValue) * 100.0
        return percentage
    }

    func updateFileSizes() {
        swiftSize = calculateFileSize(path: docdir, fileExtension: "swift")
        cSize = calculateFileSize(path: docdir, fileExtension: "c")
        cppSize = calculateFileSize(path: docdir, fileExtension: "cpp")
        objCSize = calculateFileSize(path: docdir, fileExtension: "m")
        objCppSize = calculateFileSize(path: docdir, fileExtension: "mm")

        // Calculate total size
        totalSize = swiftSize + cSize + cppSize + objCSize + objCppSize
    }

    func calculateFileSize(path: String, fileExtension: String) -> Double {
        var totalSizeKB: Double = 0.0

        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: path)

        while let file = enumerator?.nextObject() as? String {
            if !file.contains("Frameworks") && !file.contains("frameworks") && file.hasSuffix(fileExtension) {
                let filePath = (path as NSString).appendingPathComponent(file)
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileSize = attributes[FileAttributeKey.size] as? Double {
                        totalSizeKB += fileSize / 1024  // Convert bytes to kilobytes
                    }
                } catch {
                    print("Error reading file attributes for \(filePath): \(error)")
                }
            }
        }

        return totalSizeKB
    }
}

struct NestedCircleProgressView: View {
    let progressValues: [Double]
    let totalSize: Double
    let colors: [Color] = [.red, .blue, .green, .orange, .yellow]

    var body: some View {
        ZStack {
            ForEach(0..<progressValues.count) { index in
                Circle()
                    .trim(from: index == 0 ? 0.0 : CGFloat(progressValues[0..<index].reduce(0, +) / totalSize),
                          to: CGFloat(progressValues[0...index].reduce(0, +) / totalSize))
                    .stroke(colors[index], lineWidth: 20)
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
    }
}

struct statsbox: View {
    let color: Color
    let language: String
    let doub: Double
    let per: Double
    var body: some View {
        if doub != 0.0 {
        HStack {
                    Rectangle()
                        .foregroundColor(color)
                        .cornerRadius(360)
                        .frame(width: 20, height: 20)
                    Text("\(language)")
                    Spacer()
                    Text("\(String(format: "%.2f", per))% • \(String(format: "%.2f", doub)) KB")
                        .font(.system(size: 12, weight: .semibold))
                }
        }
    }
}