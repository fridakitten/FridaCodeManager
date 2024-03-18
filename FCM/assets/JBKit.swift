import Foundation

func uts(_ url: URL) -> String? {
    return url.absoluteString
}

func getBundleIdentifier(fromPlistAtPath path: String) -> String? {
    guard let plistData = FileManager.default.contents(atPath: path) else {
        return nil
    }

    do {
        let plist = try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: nil)
        if let plistDictionary = plist as? [String: Any],
           let bundleIdentifier = plistDictionary["CFBundleIdentifier"] as? String {
            return bundleIdentifier
        }
    } catch {
        print("Error reading plist: \(error)")
    }

    return nil
}