#! /usr/bin/env sh

dependency_versions()
(
  export _CROSS_GCC_VERSION="$1"
  
  printf ">> Determining GCC dependency known-to-work versions.\n"
  
  case "$_CROSS_GCC_VERSION" in
    4.6*)
      export _CROSS_VERSION_GMP="4.3.2"
      export _CROSS_VERSION_MPFR="2.4.2"
      export _CROSS_VERSION_MPC="0.8.1"
      export _CROSS_VERSION_PPL="0.11"
      export _CROSS_VERSION_CLOOG_PPL="0.15.9"
      ;;
    4.7*)
      export _CROSS_VERSION_GMP="5.1.3"
      export _CROSS_VERSION_MPFR="3.1.2"
      export _CROSS_VERSION_MPC="1.0.1"
      export _CROSS_VERSION_PPL="1.1"
      export _CROSS_VERSION_ISL="0.12.1"
      export _CROSS_VERSION_CLOOG="0.18.1"
      ;;
    4.8*|trunk)
      export _CROSS_VERSION_GMP="5.1.3"
      export _CROSS_VERSION_MPFR="3.1.2"
      export _CROSS_VERSION_MPC="1.0.1"
      export _CROSS_VERSION_PPL="1.1"
      export _CROSS_VERSION_ISL="0.12.1"
      export _CROSS_VERSION_CLOOG="0.18.1"
      ;;
    esac

  export _CROSS_VERSION_LIBICONV="1.14"
  export _CROSS_VERSION_EXPAT="2.1.0"

  export _CROSS_VERSION_MINGW_W64="v3.0.0"

  export _CROSS_VERSION_BINUTILS="2.24"
  
  _CROSS_VERSION_GDB="7.6.2"
  _CROSS_VERSION_MAKE="4.0"

  _CROSS_PACKAGE_VERSION="--with-pkgversion=rubenvb --with-bugurl=github.com/rubenvb/cross/issues"
)