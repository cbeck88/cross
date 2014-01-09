#! /usr/bin/env sh

if [ "$UID" = "0" ]
then
  printf "cross_build.sh must not be run as root.\n"
  exit 1
fi

printf "> Determining GCC version to build.\n"
if [ "x$1" = "x" ]
then
  printf ">> Please specify GCC/LLVM version you want to build as X.X[.X] or trunk.\n"
  exit 1
else
  case "$1" in
    4.6*|4.7*|4.8*|trunk)
      export _CROSS_VERSION_GCC=$1
      printf ">> Building GCC version $_CROSS_VERSION_GCC.\n"
      ;;
    *)
      printf "Error: unsupported GCC version: $1.\n"
      exit 1
      ;;
  esac
fi

printf "> Loading functions.\n"
. ./functions.sh

# printf "> Fetching sources.\n"
# . ./fetch_sources.sh

printf "> Checking executables needed for the build process.\n"
check_prerequisites

# build options
_CROSS_NPROC=`nproc`
_CROSS_MAKE_ARGS="-j$_CROSS_NPROC"

# get build machine GCC triplet
_CROSS_BUILD=`gcc -dumpmachine`

printf "> Setting up directories.\n"
. ./directories.sh

printf "> Building MinGW compilers.\n"

case "$_CROSS_BUILD" in
  *linux*)
    build_gnu_toolchain "linux64mingw32" || exit 1
#     build_gnu_toolchain "linux64mingw64" || exit 1
#     
#     build_gnu_toolchain "linux32mingw32" || exit 1
#     build_gnu_toolchain "linux32mingw64" || exit 1

    printf ">> Extracting cross-compilers.\n"
    cd "$_CROSS_COMPILER_DIR"
    rm -rf mingw32
    tar -xf "$_CROSS_PACKAGE_DIR/linux64mingw32_gcc-${_CROSS_VERSION_GCC}_rubenvb$_CROSS_COMPRESS_EXT" || exit 1
    ;;
  *cygwin*)
    printf "Warning: building on Cygwin untested!\n"
    build_gnu_toolchain "cygwin32mingw32" || exit 1
    build_gnu_toolchain "cygwin32mingw64" || exit 1
    ;;
  *darwin*)
    printf "Warning: building on Mac untested!\n"
    build_gnu_toolchain "mac64mingw32" || exit 1
    build_gnu_toolchain "mac64mingw64" || exit 1
    ;;
  *mingw*)
    printf "Error: building on Windows won't work!\n"
    exit 1
    ;;
  *)
    printf "Error: building on $_CROSS_BUILD won't work!\n"
    ;;
esac

printf "> Building native GCC toolchains.\n"

export PATH=$_CROSS_COMPILER_DIR/mingw32/bin:$_CROSS_COMPILER_DIR/mingw64/bin:$PATH

build_gnu_toolchain "mingw32mingw32" || exit 1
# build_gnu_toolchain "mingw32mingw64" || exit 1
# build_gnu_toolchain "mingw32mingw32-dw2" || exit 1
# build_gnu_toolchain "mingw32mingw64-sjlj" || exit 1
# 
# build_gnu_toolchain "mingw64mingw32" || exit 1
# build_gnu_toolchain "mingw64mingw64" || exit 1
# build_gnu_toolchain "mingw64mingw32-dw2" || exit 1
# build_gnu_toolchain "mingw64mingw64-sjlj" || exit 1

printf "All done!\n"
