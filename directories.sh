#! /bin/env sh

printf ">>> Defining Cross directory tree.\n"
_CROSS_DIR="`pwd`"
_CROSS_SOURCE_DIR="$_CROSS_DIR/src"
_CROSS_PATCH_DIR="$_CROSS_DIR/patches"
_CROSS_BUILD_DIR="$_CROSS_DIR/build"
_CROSS_PREREQ_DIR="$_CROSS_BUILD_DIR/prerequisites"
_CROSS_PACKAGE_DIR="$_CROSS_DIR/packages"
_CROSS_LOG_DIR="$_CROSS_DIR/logs"

printf ">>> Creating Cross directory tree.\n"
mkdir -p "$_CROSS_SOURCE_DIR" "$_CROSS_BUILD_DIR" "$_CROSS_PACKAGE_DIR" "$_CROSS_LOG_DIR" "$_CROSS_PREREQ_DIR"
