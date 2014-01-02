#! /usr/bin/env sh
set -e

if [[ $UID -e 0 ]];
then
  printf "cross_build must not be run as root.\n"
  exit 1
fi

printf ">> Loading functions.\n"
. ./functions.sh

printf ">> Loading versions information.\n"
. ./versions.sh

printf ">> Checking for interfering cross-compilers.\n"
check_executables "i686-w64-mingw32-ld" "i686-w64-mingw32-gcc" "x86_64-w64-mingw32-ld" "x86_64-w64-mingw32-gcc" || printf ">>> None found.\n"

printf ">> Checking for required executables.\n"
check_executables "gcc" "flex" "bison" "makeinfo" "7z" "svn" "git" "make" "python" "curl" "patch"
check_executables "python"
printf ">> Checking executable versions.\n"
printf ">>> Python\n"
case `python -c 'import platform; print(platform.python_version())'` in
  3.?.?)
    printf ">>> 'python' is version 3. We (LLVM) need(s) version 2.\n"
    check_executables "python2"
    _CROSS_PYTHON2="python2" ;;
  2.?.?)
    printf ">>> 'python is version 2.\n"
    _CROSS_PYTHON2="python" ;;
  *)
    printf ">>> Could not detect Python version. Exiting.\n"
    exit 1 ;;
esac
printf ">>> Python version 2 found with command $_CROSS_PYTHON2.\n"

# build options
_CROSS_NPROC=`nproc`
_CROSS_MAKE_ARGS="-j1$_CROSS_NPROC"

# get build machine GCC triplet
_CROSS_BUILD=`gcc -dumpmachine`

printf ">> Setting up directories.\n"
. ./directories.sh
