# Compile function
compile() {
    local name=$1
    local sources=$2
    local output="shell/output/$name"
    if [ $name = "neofetch" ]; then
        if clang $sources shell/neofetch/*.m -framework Foundation -framework UIKit -o $output; then
            echo -e "$name compiled"
        else
            echo -e "$name did not compile successfully\n"
            exit 255
        fi
    else
        if clang $sources -o $output; then
            echo -e "$name compiled"
        else
            echo -e "$name did not compile successfully\n"
            exit 255
        fi
    fi
}

# Sign function
sign() {
    local name=$1
    local entitlements="shell/$name/entitlements.plist"
    local output="shell/output/$name"
    if ldid -S$entitlements $output; then
        echo -e "$name entitled"
    else
        echo -e "$name did not entitle\n"
        exit 255
    fi
}

# Move function
move() {
    local name=$1
    local destination=$2
    if mv "shell/output/$name" $destination; then
        echo -e "$name moved"
    else
        echo -e "$name did not move\n"
        exit 255
    fi
}

# List of shell programs
programs=("ls" "mkdir" "rmdir" "rm" "cp" "echo" "chmod" "chown" "grep" "cat" "ping" "id" "ln" "touch" "mv" "whoami" "hostname")

# Compile stage
echo -e "\033[32mcompiling NoWayStrap\e[0m"
for program in "${programs[@]}"; do
    compile $program "shell/$program/*.c"
done

# Sign stage
echo -e "\033[32mentitleing NoWayStrap\e[0m"
for program in "${programs[@]}"; do
    sign $program
done
