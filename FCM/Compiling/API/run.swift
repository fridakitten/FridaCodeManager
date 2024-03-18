//
//SPARKCODE API
//made by. Frida and SeanIsTethered
//

func api(_ text: String,_ Project:Project) -> ext {
    //before tag
    var before: String = tags(text,"before")
    before = apicall(before,Project)
    //build tag
    var build: String = tags(text,"build")
    build = apicall(build,Project)
    //after tag
    var after: String = tags(text,"after")
    after = apicall(after,Project)

    return ext(before:before,flag:build,after:after)
}