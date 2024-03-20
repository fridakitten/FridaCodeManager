 /* 
 Shell.swift 

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
    
import Foundation
import Darwin

@discardableResult func shell(_ command: String, uid: uid_t? = 501) -> Int {
    return runCommand("/usr/bin/bash", ["-c", command], (uid ?? 501))
}

// Define C functions
@_silgen_name("posix_spawnattr_set_persona_np")
func posix_spawnattr_set_persona_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t, _ flags: UInt32)
@_silgen_name("posix_spawnattr_set_persona_uid_np")
func posix_spawnattr_set_persona_uid_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t)
@_silgen_name("posix_spawnattr_set_persona_gid_np")
func posix_spawnattr_set_persona_gid_np(_ attr: UnsafeMutablePointer<posix_spawnattr_t?>, _ persona_id: uid_t)

func runCommand(_ command: String, _ args: [String], _ uid: uid_t, _ rootPath: String = jbroot) -> Int {
    var pid: pid_t = 0
    let args: [String] = [String(command.split(separator: "/").last!)] + args
    let argv: [UnsafeMutablePointer<CChar>?] = args.map { $0.withCString(strdup) }
    let env = ["PATH=/usr/local/sbin:\(rootPath)/usr/local/sbin:/usr/local/bin:\(rootPath)/usr/local/bin:/usr/sbin:\(rootPath)/usr/sbin:/usr/bin:\(rootPath)/usr/bin:/sbin:\(rootPath)/sbin:/bin:\(rootPath)/bin:/usr/bin/X11:\(rootPath)/usr/bin/X11:/usr/games:\(rootPath)/usr/games"]
    let proenv: [UnsafeMutablePointer<CChar>?] = env.map { $0.withCString(strdup) }
    defer { for case let pro? in proenv { free(pro) } }
    var attr: posix_spawnattr_t?
    posix_spawnattr_init(&attr)
    posix_spawnattr_set_persona_np(&attr, 99, 1)
    posix_spawnattr_set_persona_uid_np(&attr, uid)
    posix_spawnattr_set_persona_gid_np(&attr, uid)
    guard posix_spawn(&pid, rootPath + command, nil, &attr, argv + [nil], proenv + [nil]) == 0 else {
        print("Failed to spawn process")
        return -1
    }
    var status: Int32 = 0
    waitpid(pid, &status, 0)
    return Int(status)
}