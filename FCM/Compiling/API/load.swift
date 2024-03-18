func load(_ file: String) -> String {
    do {
        return try String(contentsOfFile: file)
    } catch {
        return ""
    }
}