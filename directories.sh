#! /bin/env sh

_CROSS_DIR="`pwd`"
_CROSS_DOWNLOAD_DIR="$_CROSS_DIR/download"
_CROSS_SOURCE_DIR="$_CROSS_DIR/src"
_CROSS_PATCH_DIR="$_CROSS_DIR/patches"
_CROSS_BUILD_DIR="$_CROSS_DIR/build"
_CROSS_TMP_DIR="/tmp/cross"
_CROSS_STAGE_DIR="$_CROSS_TMP_DIR/stage"
_CROSS_STAGE_INSTALL_DIR="$_CROSS_TMP_DIR/stage-install"
_CROSS_PACKAGE_DIR="$_CROSS_DIR/packages"
_CROSS_LOG_DIR="$_CROSS_DIR/logs"
_CROSS_COMPILER_DIR="$_CROSS_DIR/compilers"

if [ "$1" = "clean" ]
then
  exit 0
fi

mkdir -p "$_CROSS_DOWNLOAD_DIR"
mkdir -p "$_CROSS_SOURCE_DIR"
mkdir -p "$_CROSS_BUILD_DIR"
mkdir -p "$_CROSS_PACKAGE_DIR"
mkdir -p "$_CROSS_LOG_DIR"
mkdir -p "$_CROSS_STAGE_DIR"
mkdir -p "$_CROSS_STAGE_INSTALL_DIR"
mkdir -p "$_CROSS_COMPILER_DIR"

rm -rf "$_CROSS_STAGE_DIR"/*
rm -rf "$_CROSS_STAGE_INSTALL_DIR"/*
rm -rf "$_CROSS_COMPILER_DIR"/*
