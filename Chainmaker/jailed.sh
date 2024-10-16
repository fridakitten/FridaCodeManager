# prepare #
if [ -d .tmp ]; then
    rm -rf .tmp
fi
mkdir -p .tmp .tmp/procursus .tmp/toolchain .tmp/toolchain/bin .tmp/toolchain/lib

# toolchain packages download #
packages=("libiosexec1" "libedit0" "libzstd1" "libxar1" "ld64" "libtapi" "libllvm16" "libclang-cpp16" "clang-16" "libclang-common-16-dev" "libssl3")

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

# toolchain creation #
echo -e "\033[32mcreating toolchain\e[0m"

## ENV ##
echo -e "\e[38;5;208msetting environment\e[0m"
ROOT_BIN=.tmp/procursus/var/jb/usr/bin
ROOT_LIB=.tmp/procursus/var/jb/usr/lib
ROOT_RPATH=/var/jb/usr/lib
CHAIN_BIN=.tmp/toolchain/bin
CHAIN_LIB=.tmp/toolchain/lib
CHAIN_RPATH=@loader_path/../lib

## COPY STAGE ##
echo -e "\e[38;5;208mcopy stage\e[0m"
libraries=("libedit.0.dylib" "libiosexec.1.dylib" "libzstd.1.dylib" "libxar.1.dylib" "libtapi.dylib" "libcrypto.3.dylib")

for library in "${libraries[@]}"; do
    cp -L $ROOT_LIB/$library $CHAIN_LIB/$library
done

## Special Stuff ##
# copy patched llvm to toolchain
cp $ROOT_LIB/llvm-16/bin/clang-16 $CHAIN_BIN/clang-16
cp $ROOT_BIN/ld64 $CHAIN_BIN/ld64
rm $ROOT_LIB/llvm-16/lib/libLLVM-16.dylib
cp -rL $ROOT_LIB/llvm-16/lib/*.dylib $CHAIN_LIB
rm -rf $ROOT_LIB/llvm-16/lib/clang/16.0.0/lib
cp -r $ROOT_LIB/llvm-16/lib/clang $CHAIN_LIB

## @RPATH PATCH ##
echo -e "\e[38;5;208mpatching @rpath\e[0m"
for dir in $CHAIN_BIN $CHAIN_LIB; do
    for file in "$dir"/*; do
        if [ ! -d "$file" ]; then
            # nobody listens to you XD
            install_name_tool -delete_rpath $ROOT_RPATH "$file" > /dev/null 2>&1
            if ! install_name_tool -add_rpath $CHAIN_RPATH "$file" > /dev/null 2>&1; then
                echo "failed to relink $file"
            else
                echo "relinked $file"
            fi
        fi
    done
done

## making the dylibification ##
make -C dylibify all
dylibify/Dylibify $CHAIN_BIN/clang-16
dylibify/Dylibify $CHAIN_BIN/ld64
mv $CHAIN_BIN/clang-16 $CHAIN_BIN/clang.dylib
mv $CHAIN_BIN/ld64 $CHAIN_BIN/ld.dylib
rm dylibify/Dylibify
