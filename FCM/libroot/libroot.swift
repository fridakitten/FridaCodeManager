func findroot() -> String {
    return String(cString: libroot_dyn_get_jbroot_prefix())
}
