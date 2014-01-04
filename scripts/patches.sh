#! /usr/bin/env sh

case "$_CROSS_GCC_VERSION" in
  4.5*)
    export _CROSS_PATCH_GCC="gcc-4.5-texinfo-5.0"
    ;;
  4.6*)
    export _CROSS_PATCH_GCC="gcc-4.6-texinfo-5.0"
    ;;
  4.7*)
    export _CROSS_PATCH_GCC="gcc-4.7-texinfo-5.0 gcc-cloog-LANGUAGE_C"
    ;;
  4.8*)
    export _CROSS_PATCH_GCC=
    ;;
esac
