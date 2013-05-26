#! /bin/env sh

echo "--> Defining Cross directory tree"
_CROSS_DIR="`pwd`"
_CROSS_SOURCE="$_CROSS_DIR/src"
_CROSS_PATCHES="$_CROSS_DIR/patches"
_CROSS_BUILD="$_CROSS_DIR/build"
_CROSS_PACKAGES="$_CROSS_DIR/packages"
_CROSS_LOGS="$_CROSS_DIR/logs"

echo "--> Creating Cross directory tree"
mkdir -p "$_CROSS_SOURCE" "$_CROSS_BUILD" "$_CROSS_PACKAGES" "$_CROSS_LOGS"
