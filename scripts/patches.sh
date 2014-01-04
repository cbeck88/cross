#! /usr/bin/env sh


case $_CROSS_VERSION_MPFR in
  2.4.2)
    export _CROSS_PATCH_MPFR="mpfr-2.4.2p3"
    ;;
  3.1.2)
    export _CROSS_PATCH_MPFR="mpfr-3.1.2p5"
    ;;
  *)
    export _CROSS_PATCH_MPFR=
    ;;
esac

case "$_CROSS_VERSION_GCC" in
  4.6*)
    export _CROSS_PATCH_GCC="gcc-4.6-texinfo-5.0 gcc-cloog-LANGUAGE_C"
    ;;
  4.7*)
    export _CROSS_PATCH_GCC="gcc-4.7-texinfo-5.0 gcc-cloog-LANGUAGE_C"
    ;;
  4.8*)
    export _CROSS_PATCH_GCC=
    ;;
esac