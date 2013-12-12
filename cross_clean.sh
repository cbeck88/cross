#! /usr/bin/env sh
set -e

printf "> Cleaning build directory and logs.\n"
printf ">> Setting up directories.\n"
. ./directories.sh

rm -rf "$_CROSS_BUILD_DIR"
rm -rf "$_CROSS_LOG_DIR"
