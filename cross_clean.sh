#! /usr/bin/env sh
set -e

printf "> Cleaning build directory and logs.\n"
. ./directories.sh clean

rm -rf "$_CROSS_BUILD_DIR"
rm -rf "$_CROSS_LOG_DIR"
rm -rf "$_CROSS_STAGE_DIR"
rm -rf "$_CROSS_STAGE_INSTALL_DIR"
rm -rf "$_CROSS_SOURCE_DIR"
