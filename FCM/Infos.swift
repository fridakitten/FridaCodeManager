/*
     Infos.swift

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


// C languages and their file extensions
let CLangsExts = [
	".m", ".mm", // ObjC(++)
	".c", ".h", // C and header (usable for other languages ofc)
	".cpp", ".cc", ".cxx", ".hpp" // C++ and header
]

// Global variables
let jbroot: String = {
    let preroot: String = String(cString: libroot_dyn_get_jbroot_prefix())
    if !fe(preroot) {
        if let altroot = altroot(inPath: "/var/containers/Bundle/Application")?.path {
            return altroot
        }
    }
    return preroot
}()
let global_documents: String = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].path
}()
let global_sdkpath: String = "\(global_documents)/../.sdk"
let global_version: String = "v1.4 (non-release)"
