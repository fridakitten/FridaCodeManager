import Foundation

func exportProj(_ project: Project) {
    let doc = docsDir()
    let target = "\(doc)/\(project.Executable).sproj"
    if fileExists(path: target) {
        shell("rm '\(doc)/\(project.Executable).sproj'")
    }
    shell("cd '\(doc)' && zip -r '\(project.Executable).sproj' '\(project.Name)'")
}

func importProj() {
    let doc = docsDir()
    let target = "\(doc)/target.sproj"
    if fileExists(path: target) {
        shell("cd '\(doc)' && unzip '\(target)'")
        shell("rm '\(target)'")
    }
}

func fileExists(path: String) -> Bool {
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: path)
}