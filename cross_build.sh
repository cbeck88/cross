#! /usr/bin/env sh

if [[ $UID -e 0 ]]
then
  printf "$0 must not be run as root.\n"
  exit 1
fi

printf ">> Loading functions.\n"
. ./functions.sh

printf ">> Loading versions information.\n"
. ./versions.sh

printf ">> Checking for interfering cross-compilers.\n"
check_executables "i686-w64-mingw32-ld" "i686-w64-mingw32-gcc" "x86_64-w64-mingw32-ld" "x86_64-w64-mingw32-gcc" || printf ">>> None found.\n"


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

printf ">> Adding cross tools (dw2) to PATH.\n"
export PATH="$_CROSS_BUILD_DIR/$_CROSS_BUILD/mingw32-dw2/mingw32-dw2/bin":$PATH

build_gnu_toolchain "mingw32-dw2"

printf "All done!\n"
