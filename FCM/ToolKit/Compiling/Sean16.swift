
func runtime_sean16(_ project: Project) -> Void {
    // compiling for Sean16 architecture
    sean16compiler("sean16compiler \(project.ProjectPath)/main.asm \(project.ProjectPath)/main.bin")

    // spawning process in Sean16CPU
    kickstart("\(project.ProjectPath)/main.bin")
}
