import Foundation

func apicall(_ text: String,_ proj:Project) -> String {
    var ret = text
    ret = ret.replacingOccurrences(of: "<ver>", with: "1.0.1")
    ret = ret.replacingOccurrences(of: "<bundle>", with: Bundle.main.bundlePath)
    ret = ret.replacingOccurrences(of: "<actionpath>", with: docsDir())
    ret = ret.replacingOccurrences(of: "<projpath>", with: "\(docsDir())/\(proj.Name)")
    ret = ret.replacingOccurrences(of: "<app>", with: "\(proj.Executable)")
    ret = repla(ret)
    ret = rsc(ret)
    return ret
}

func repla(_ inputString: String) -> String {
    return inputString.replacingOccurrences(of: "\n", with: " ; ")
}

func rsc(_ inputString: String) -> String {
    var trimmedString = inputString.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if trimmedString.hasPrefix("; ") {
        trimmedString.removeFirst()
    }
    
    if trimmedString.hasSuffix(" ;") {
        trimmedString.removeLast()
    }
    
    return trimmedString
}
