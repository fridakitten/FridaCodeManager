// Basically the "bootup" of FridaCodeManager

// fatal error handling
func exitWithError(_ message: String) -> Never {
    fatalError(message)
}

// jbroot environment
#if jailbreak
let jbroot: String = {
    let preroot = String(cString: libroot_dyn_get_jbroot_prefix())
    if FileManager.default.fileExists(atPath: preroot) {
        return preroot
    } else if let altroot = altroot(inPath: "/var/containers/Bundle/Application")?.path {
        return altroot
    } else {
        exitWithError("failed to determine jbroot")
    }
}()
#elseif trollstore
let jbroot: String = "\(Bundle.main.bundlePath)/toolchain"
#endif

// global environment
let global_container: String = {
    guard let path = contgen() else {
        exitWithError("failed to generate global container")
    }
    return path
}()

let global_documents = "\(global_container)/Documents"

#if !stock
let global_sdkpath = "\(global_container)/.sdk"
#else
let global_sdkpath = "\(global_documents)/.sdk"
#endif

let changelog: String = "v1.6 \"Responsiveness Update\"\n\nApp\n-> refined permission levels throughout the codebase to ensure more consistent access control\n-> fixed an issue where corrupted projects could not be loaded. Users can now successfully open these projects, providing the ability to either repair or delete them—an option that was previously unavailable. This ensures greater control over managing project data and prevents unnecessary project lockouts.\n-> resolved issues with exporting apps and projects, ensuring the export process behaves as expected\n-> fixed the display of the app icon in the Documents app on files associated with FCM\n-> importing via file actions now only supports .sproj to be imported\n-> resolved an issue in the credits sheet with profile picture loading, ensuring that images now load consistently and reliably in nearly all cases, significantly improving the user experience when viewing profiles\n\nFileManager\n-> introduced multithreading support, allowing users to open folders seamlessly, improving responsiveness when navigating large directories.\n-> implemented file grouping to organize files more effectively and prevent clutter within folders\n-> created a global function for file loading, reducing code duplication and improving maintainability\n-> added smooth animations to all file loading processes to enhance the user experience\n\nPopup\n-> introduced visually appealing animations for popups, improving user interaction and engagement\n-> enhanced popup sizing logic to resolve common bugs related to improper popup display and scaling\n\nCodeEditor\n-> removed an unnecessary child view to streamline the interface and improve performance\n-> eliminated inefficient color reloading during the file opening process, resulting in faster file handling"
let global_version: String = "v1.6"
