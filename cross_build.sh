#! /usr/bin/env sh

printf "> Preparing.\n"
. ./prepare.sh

printf "> Fetching sources.\n"
. ./fetch_sources.sh

printf ">> Adding cross tools to PATH.\n"
export PATH="$_CROSS_BUILD_DIR/$_CROSS_BUILD/mingw32/mingw32/bin":"$_CROSS_BUILD_DIR/$_CROSS_BUILD/mingw64/mingw64/bin":$PATH

printf "> Building cross-compilers.\n"
build_gnu_toolchain "mingw32"
build_gnu_toolchain "mingw64"
#build_gnu_toolchain "cygwin32"
#build_gnu_toolchain "cygwin64"

#printf "> Building Canadian Cross compilers.\n"
#build_gnu_toolchain "mingw32" "i686-pc-cygwin"
#build_gnu_toolchain "mingw64" "i686-pc-cygwin"
#build_gnu_toolchain "mingw32" "x86_64-pc-cygwin"
#build_gnu_toolchain "mingw64" "x86_64-pc-cygwin"

printf "> Building native compilers.\n"
build_gnu_toolchain "mingw32" "i686-w64-mingw32"
build_gnu_toolchain "mingw64" "i686-w64-mingw32"
build_gnu_toolchain "mingw32" "x86_64-w64-mingw32"
build_gnu_toolchain "mingw64" "x86_64-w64-mingw32"

printf ">> Adding cross tools to PATH.\n"
export PATH="$_CROSS_BUILD_DIR/$_CROSS_BUILD/mingw32-dw2/mingw32-dw2/bin":$PATH

build_gnu_toolchain "mingw32-dw2"

printf "All done!\n"
