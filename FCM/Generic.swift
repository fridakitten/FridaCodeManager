import UIKit

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

let changelog: String = "v2.0.alpha_3 \"iPad + Code Editor Update\"\n\nApp\n-> moved \"Cleaner\" to additional tools\n-> added missing credits\n-> improved + fixed bash-safety-check\n-> fixed support for multiline word Utility names\n\nCode Editor\n-> added auto tabbing"
let global_version: String = "v2.0.alpha_3"

// compatibiloty checks
let isiOS16: Bool = ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 16, minorVersion: 0, patchVersion: 0))

let isPad: Bool = {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return true
    } else {
        return false
    }
}()
