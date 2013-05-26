#! /usr/bin/env sh

echo "Loading functions"
. ./functions.sh

echo "Loading versions information"
. ./versions.sh

echo "Performing system setup"
echo "-> Checking for required executables"
check_executables "gcc" "flex" "bison" "makeinfo" "7z" "svn" "git" "make" "python" "curl" "patch"
check_executables "python"
echo "-> Checking executable versions"
echo "--> Python"
case `python -c 'import platform; print(platform.python_version())'` in
  3.?.?)
    echo "--> 'python' is version 3. We (LLVM) need(s) version 2."
    check_executables "python2"
    _CROSS_PYTHON2="python2" ;;
  2.?.?)
    echo "--> 'python is version 2."
    _CROSS_PYTHON2="python" ;;
  *)
    echo "--> Could not detect Python version. Exitin."
    exit 1 ;;
esac
echo "--> Python version 2 found with command $_CROSS_PYTHON2"

echo "Setting up directories"
. ./directories.sh

_CROSS_BUILD=`gcc -dumpmachine`

echo "Downloading sources"
. ./download_sources.sh
