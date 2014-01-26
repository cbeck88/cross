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
  x86_64-*-linux*)
    shorthost="linux64" ;;
  i686-*-linux*)
    shorthost="linux32" ;;
  *cygwin*)
    shorthost="cygwin32" ;;
  i686-*-darwin*)
    shorthost="mac32" ;;
  x86_64-*-darwin*)
    shorthost="mac64" ;;
  *mingw*)
    printf "Error: building on Windows might work, but is disabled!\n"
    exit 1 ;;
  *)
    printf "Error: building on $_CROSS_BUILD won't work!\n"
    ;;
esac

build_gnu_toolchain "${shorthost}mingw32" || exit 1
build_gnu_toolchain "${shorthost}mingw64" || exit 1
build_gnu_toolchain "${shorthost}mingw32-dw2" || exit 1
build_gnu_toolchain "${shorthost}mingw64-sjlj" || exit 1

printf ">> Extracting cross-compilers.\n"
decompress=$(package_decompress $host)
ext=$(package_ext $host)
cd "$_CROSS_COMPILER_DIR"
rm -rf mingw32*
$decompress "$_CROSS_PACKAGE_DIR/${shorthost}mingw32_gcc-${_CROSS_VERSION_GCC}_rubenvb$ext" || exit 1
rm -rf mingw64*
$decompress "$_CROSS_PACKAGE_DIR/${shorthost}mingw64_gcc-${_CROSS_VERSION_GCC}_rubenvb$ext" || exit 1

export PATH=$_CROSS_COMPILER_DIR/mingw32/bin:$_CROSS_COMPILER_DIR/mingw64/bin:$PATH

printf "> Building native GCC toolchains.\n"

build_gnu_toolchain "mingw32mingw32" || exit 1
build_gnu_toolchain "mingw32mingw64" || exit 1
build_gnu_toolchain "mingw64mingw32" || exit 1
build_gnu_toolchain "mingw64mingw64" || exit 1

printf ">> Extracting dw2/sjlj cross-compilers.\n"
cd "$_CROSS_COMPILER_DIR"
rm -rf mingw32*
$decompress "$_CROSS_PACKAGE_DIR/${shorthost}mingw32-dw2_gcc-${_CROSS_VERSION_GCC}_rubenvb$ext" || exit 1
rm -rf mingw64*
$decompress "$_CROSS_PACKAGE_DIR/${shorthost}mingw64-sjlj_gcc-${_CROSS_VERSION_GCC}_rubenvb$ext" || exit 1

export PATH=$_CROSS_COMPILER_DIR/mingw32-dw2/bin:$_CROSS_COMPILER_DIR/mingw64-sjlj/bin:$PATH

build_gnu_toolchain "mingw32mingw32-dw2" || exit 1
build_gnu_toolchain "mingw64mingw32-dw2" || exit 1
build_gnu_toolchain "mingw32mingw64-sjlj" || exit 1
build_gnu_toolchain "mingw64mingw64-sjlj" || exit 1

rm -rf "$_CROSS_STAGE_DIR"
rm -rf "$_CROSS_STAGE_INSTALL_DIR"
rm -rf "$_CROSS_COMPILER_DIR"

printf "All done!\n"
