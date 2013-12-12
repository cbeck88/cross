#! /usr/bin/env sh
set -e

printf ">> Loading functions.\n"
. ./functions.sh

printf ">> Loading versions information.\n"
. ./versions.sh

printf ">> Checking for required executables.\n"
check_executables "gcc" "flex" "bison" "makeinfo" "7z" "svn" "git" "make" "python" "curl" "patch"
check_executables "python"
printf ">> Checking executable versions.\n"
printf ">>> Python"
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
_CROSS_MAKE_ARGS="-j4"

# get build machine GCC triplet
_CROSS_BUILD=`gcc -dumpmachine`

printf ">> Setting up directories.\n"
. ./directories.sh