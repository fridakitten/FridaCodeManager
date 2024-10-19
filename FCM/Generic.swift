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

let changelog: String = "v1.5.6 \"Fixes\"\n\nApp\n-> Fixed Entitlements\n-> improved Info.plist of FCM\n-> fixed the pfp loader of the credits\n\nSeansBuild\n-> Using libproc to kill apps"
let global_version: String = "v1.5.6"
