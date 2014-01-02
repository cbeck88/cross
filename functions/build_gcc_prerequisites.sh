#! /usr/bin/env sh

build_gcc_prerequisites()
(
  host="$1"

  # Directories
  mkdir -p "$_CROSS_LOG_DIR/$host"
  prereq_build="$_CROSS_PREREQ_DIR/$host"
  prereq_install="$prereq_build/install"
  mkdir -p "$prereq_build" && cd "$prereq_build"

  gmpconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                    --disable-shared --enable-static \
                    --enable-cxx"
                    #CC=$host-gcc CXX=$host-g++
  build_with_autotools "gmp" "$prereq_build" "$_CROSS_VERSION_GMP" "$_CROSS_LOG_DIR/$host" \
                      "$gmpconfigureargs" "$_CROSS_MAKE_ARGS"

  mpfrconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                     --disable-shared --enable-static \
                     --with-gmp=$prereq_install"
  build_with_autotools "mpfr" "$prereq_build" "$_CROSS_VERSION_MPFR" "$_CROSS_LOG_DIR/$host" \
                      "$mpfrconfigureargs" "$_CROSS_MAKE_ARGS"

  mpcconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                    --disable-shared --enable-static \
                    --with-gmp=$prereq_install --with-mpfr=$prereq_install"
  build_with_autotools "mpc" "$prereq_build" "$_CROSS_VERSION_MPC" "$_CROSS_LOG_DIR/$host" \
                      "$mpcconfigureargs" "$_CROSS_MAKE_ARGS"

  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      if [ "$host" = "*-*-mingw32" ]
      then
        printf ">>> Removing previous PPL build to prevent C++ ABI breakage.\n"
        rm -rf "$prereq_build/ppl"
      fi
      pplconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                        --disable-shared --enable-static \
                        --with-gmp=$prereq_install"
      build_with_autotools "ppl" "$prereq_build" "$_CROSS_VERSION_PPL" "$_CROSS_LOG_DIR/$host" \
                           "$pplconfigureargs" "$_CROSS_MAKE_ARGS -j1" ;;
  esac

  islconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                    --disable-shared --enable-static \
                    --with-gmp-prefix=$prereq_install"
  build_with_autotools "isl" "$prereq_build" "$_CROSS_VERSION_ISL" "$_CROSS_LOG_DIR/$host" \
                      "$islconfigureargs" "$_CROSS_MAKE_ARGS"

  cloogconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                      --disable-shared --enable-static \
                      --with-gmp-prefix=$prereq_install --with-bits=gmp --with-isl=system"
  build_with_autotools "cloog" "$prereq_build" "$_CROSS_VERSION_CLOOG" "$_CROSS_LOG_DIR/$host" \
                       "$cloogconfigureargs" "$_CROSS_MAKE_ARGS"

  case $host in
    *-*-mingw32|*-*-cygwin)
      libiconvconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                             --disable-shared --enable-static"
      build_with_autotools "libiconv" "$prereq_build" "$_CROSS_VERSION_LIBICONV" "$_CROSS_LOG_DIR/$host" \
                           "$libiconvconfigureargs" "$_CROSS_MAKE_ARGS"
      expatconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                          --disable-shared --enable-static"
      build_with_autotools "expat" "$prereq_build" "$_CROSS_VERSION_EXPAT" "$_CROSS_LOG_DIR/$host" \
                           "$expatconfigureargs" "$_CROSS_MAKE_ARGS" ;;
  esac
)
