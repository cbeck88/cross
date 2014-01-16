#! /usr/bin/env sh

case $_CROSS_VERSION_MPFR in
  2.4.2)
    export _CROSS_PATCHES_MPFR="mpfr-2.4.2p3"
    ;;
  3.1.2)
    export _CROSS_PATCHES_MPFR="mpfr-3.1.2p5"
    ;;
  *)
    export _CROSS_PATCHES_MPFR=
    ;;
esac

case "$_CROSS_VERSION_GCC" in
  4.6*)
    export _CROSS_PATCHES_GCC="gcc-4.6-texinfo-5.0 gcc-cloog-LANGUAGE_C gcc-4.6-posix_threads"
    ;;
  4.7.[0-2])
    export _CROSS_PATCHES_GCC="gcc-4.7-texinfo-5.0 gcc-cloog-LANGUAGE_C gcc-4.7.pre3-segfault gcc-4.7-posix_threads"
    ;;
  4.7*)
    export _CROSS_PATCHES_GCC="gcc-4.7-posix_threads"
    ;;
  4.8*)
    export _CROSS_PATCHES_GCC=
    ;;
esac

export _CROSS_PATCHES_MAKE="make-win32"
