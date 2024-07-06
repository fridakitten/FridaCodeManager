# prepare
if [ -d .tmp ]; then
    rm -rf .tmp
fi
mkdir -p .tmp .tmp/procursus .tmp/toolchain

# toolchain packages download
packages=("coreutils" "libreadline8" "libiosexec1" "libncursesw6" "libintl8" "libssl3" "libedit0" "libzstd1" "libxar1" "dash" "ld64" "libuuid16" "libtapi" "odcctools" "libllvm16" "libclang-cpp16" "clang-16" "libclang-common-16-dev" "ldid" "zip" "unzip" "libplist3" "shell-cmds")

for package in "${packages[@]}"; do
    echo -e "\e[38;5;208mdownloading $package\e[0m"
    cd .tmp/procursus
    while ! apt download --download-only "$package" > /dev/null 2>&1; do
        echo -e "failed, retry!"
        echo -e "\e[38;5;208mdownloading $package\e[0m"
    done
    dpkg --extract "${package}"*.deb ./
    rm "${package}"*.deb
    cd ../../
done

# toolchain creation
echo -e "\033[32mcreating toolchain\e[0m"
mkdir .tmp/toolchain/bin .tmp/toolchain/lib

## ENV ##
echo -e "\e[38;5;208msetting file environment\e[0m"
ROOT_BIN=.tmp/procursus/var/jb/usr/bin
ROOT_LIB=.tmp/procursus/var/jb/usr/lib
CHAIN_BIN=.tmp/toolchain/bin
CHAIN_LIB=.tmp/toolchain/lib

## INT ENV ##
echo -e "\e[38;5;208msetting rpath environment\e[0m"
ROOT_RPATH=/var/jb/usr/lib
CHAIN_RPATH=@loader_path/../lib

echo -e "\e[38;5;208mcopy bin stage\e[0m"
## COPY BIN ##
# Base
binaries=("dash" "echo" "mkdir" "rmdir" "cp" "mv" "rm" "ls" "ld" "ln" "install_name_tool" "otool" "ldid" "zip" "unzip" "killall")

for binary in "${binaries[@]}"; do
    cp $ROOT_BIN/$binary $CHAIN_BIN/$binary
done

echo -e "\e[38;5;208mcopy lib stage\e[0m"
## COPY LIB ##
libraries=("libedit.0.dylib" "libiosexec.1.dylib" "libreadline.8.dylib" "libhistory.8.dylib" "libncursesw.6.dylib" "libintl.8.dylib" "libzstd.1.dylib" "libxar.1.dylib" "libcrypto.3.dylib" "libuuid.16.dylib" "libtapi.dylib" "libplist-2.0.3.dylib")

for library in "${libraries[@]}"; do
    cp -L $ROOT_LIB/$library $CHAIN_LIB/$library
done

# Special Dev Non Algorithmic Copying
cp $ROOT_LIB/llvm-16/bin/clang-16 $CHAIN_BIN/clang-16
cp $ROOT_LIB/llvm-16/lib/libclang-cpp.dylib $CHAIN_LIB/libclang-cpp.dylib
cp $ROOT_LIB/llvm-16/lib/libLLVM.dylib $CHAIN_LIB/libLLVM.dylib
cp $ROOT_LIB/llvm-16/lib/libLLVM-16.dylib $CHAIN_LIB/libLLVM-16.dylib
cp -r $ROOT_LIB/llvm-16/lib/clang $CHAIN_LIB

## @RPATH PATCH ##
echo -e "\e[38;5;208mpatching @rpath\e[0m"
for file in $CHAIN_BIN/*; do
    if [ ! -d $file ]; then
        install_name_tool -delete_rpath '/var/jb/usr/lib' $file
        install_name_tool -add_rpath '@loader_path/../lib' $file
        echo "relinked $file"
    fi
done
for file in $CHAIN_LIB/*; do
    if [ ! -d $file ]; then
        install_name_tool -delete_rpath '/var/jb/usr/lib' $file
        install_name_tool -add_rpath '@loader_path/../lib' $file
        echo "relinked $file"
    fi
done

## CODESIGNATURE PATCH ##
echo -e "\e[38;5;208msigning toolchain\e[0m"
for file in $CHAIN_BIN/*; do
    if [ ! -d $file ]; then
        ./fps $file > /dev/null
        echo "signed $file"
    fi
done
for file in $CHAIN_LIB/*; do
    if [ ! -d $file ]; then
        ./fps $file > /dev/null
        echo "signed $file"
    fi
done