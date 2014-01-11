#! /usr/bin/env sh

printf ">> Determining GCC dependency known-to-work versions.\n"

case "$_CROSS_VERSION_GCC" in
  4.6*|4.7*|4.8*|trunk)
    export _CROSS_VERSION_GMP="5.1.3"
    export _CROSS_VERSION_MPFR="3.1.2"
    export _CROSS_VERSION_MPC="1.0.1"
    export _CROSS_VERSION_PPL="1.1"
    export _CROSS_VERSION_ISL="0.12.1"
    export _CROSS_VERSION_CLOOG="0.18.1" # 0.18.2 has install bug
    ;;
  *)
    printf "Unknown GCC version: \n'$_CROSS_VERSION_GCC'\n.\n"
    exit 1
    ;;
esac

export _CROSS_VERSION_LIBICONV="1.14"
export _CROSS_VERSION_EXPAT="2.1.0"

export _CROSS_VERSION_MINGW_W64="v3.0.0"

export _CROSS_VERSION_BINUTILS="2.24"

export _CROSS_VERSION_PYTHON="2.7.6"
export _CROSS_VERSION_GDB="7.6.2"
export _CROSS_VERSION_MAKE="4.0"

printf ">> Setting pkgversion and bugurl information.\n"

export _CROSS_GNU_PKG_VERSION="--with-pkgversion=rubenvb --with-bugurl=github.com/rubenvb/cross/issues"
