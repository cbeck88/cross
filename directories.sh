#! /bin/env sh

echo "--> Defining Cross directory tree"
_CROSS_DIR="`pwd`"
_CROSS_SOURCE_DIR="$_CROSS_DIR/src"
_CROSS_PATCH_DIR="$_CROSS_DIR/patches"
_CROSS_BUILD_DIR="$_CROSS_DIR/build"
_CROSS_PACKAGE_DIR="$_CROSS_DIR/packages"
_CROSS_LOG_DIR="$_CROSS_DIR/logs"

_CROSS_BOOTSTRAP_DIR="$_CROSS_BUILD_DIR/bootstrap"

echo "--> Creating Cross directory tree"
mkdir -p "$_CROSS_SOURCE_DIR" "$_CROSS_BUILD_DIR" "$_CROSS_PACKAGE_DIR" "$_CROSS_LOG_DIR" "$_CROSS_BOOTSTRAP_DIR"
