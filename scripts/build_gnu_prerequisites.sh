#! /usr/bin/env sh

build_gnu_prerequisites()
(
  host="$1"

  # Directories
  mkdir -p "$_CROSS_LOG_DIR/prereq-$host"
  prereq_build="$_CROSS_BUILD_DIR/prereq-$_CROSS_VERSION_GCC-$host"
  mkdir -p "$prereq_build" && cd "$prereq_build"

  fetch_source_release "$_CROSS_URL_GNU/gmp" "gmp-$_CROSS_VERSION_GMP" "bz2"
  gmpconfigureargs="--host=$host --build=$_CROSS_BUILD \
                    --disable-shared --enable-static \
                    --enable-cxx \
                    $_CROSS_MULTILIB_ENV"
  build_with_autotools "gmp" "$prereq_build" "$_CROSS_VERSION_GMP" "$_CROSS_LOG_DIR/$host" \
                      "$gmpconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1

  fetch_source_release "$_CROSS_URL_GNU/mpfr" "mpfr-$_CROSS_VERSION_MPFR"   "xz"  "$_CROSS_PATCHES_MPFR"
  mpfrconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                     --disable-shared --enable-static \
                     --with-gmp=$prereq_install \
                     $_CROSS_MULTILIB_ENV"
  build_with_autotools "mpfr" "$prereq_build" "$_CROSS_VERSION_MPFR" "$_CROSS_LOG_DIR/$host" \
                      "$mpfrconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1

  fetch_source_release "$_CROSS_URL_GNU/mpc" "mpc-$_CROSS_VERSION_MPC" "gz"
  mpcconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                    --disable-shared --enable-static \
                    --with-gmp=$prereq_install --with-mpfr=$prereq_install \
                    $_CROSS_MULTILIB_ENV"
  build_with_autotools "mpc" "$prereq_build" "$_CROSS_VERSION_MPC" "$_CROSS_LOG_DIR/$host" \
                      "$mpcconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1

  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      if [ "$host" = "*-*-mingw32" ]
      then
        printf ">>> Removing previous PPL build to prevent C++ ABI breakage.\n"
        rm -rf "$prereq_build/ppl"
      fi
      fetch_source_release "$_CROSS_URL_PPL" "ppl-$_CROSS_VERSION_PPL" "gz"
      pplconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                        --disable-shared --enable-static \
                        --with-gmp=$prereq_install \
                        $_CROSS_MULTILIB_ENV"
      build_with_autotools "ppl" "$prereq_build" "$_CROSS_VERSION_PPL" "$_CROSS_LOG_DIR/$host" \
                           "$pplconfigureargs" "$_CROSS_MAKE_ARGS -j1" || exit 1
  esac

  fetch_source_release "$_CROSS_URL_ISL" "isl-$_CROSS_VERSION_ISL" "bz2"
  islconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                    --disable-shared --enable-static \
                    --with-gmp-prefix=$prereq_install \
                    $_CROSS_MULTILIB_ENV"
  build_with_autotools "isl" "$prereq_build" "$_CROSS_VERSION_ISL" "$_CROSS_LOG_DIR/$host" \
                      "$islconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1

  fetch_source_release "$_CROSS_URL_CLOOG" "cloog-$_CROSS_VERSION_CLOOG" "gz"
  cloogconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                      --disable-shared --enable-static \
                      --with-gmp-prefix=$prereq_install --with-bits=gmp \
                      $_CROSS_MULTILIB_ENV"
  build_with_autotools "cloog" "$prereq_build" "$_CROSS_VERSION_CLOOG" "$_CROSS_LOG_DIR/$host" \
                       "$cloogconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1

  fetch_source_release "$_CROSS_URL_EXPAT" "expat-$_CROSS_VERSION_EXPAT" "gz"
  expatconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                      --disable-shared --enable-static \
                      $_CROSS_MULTILIB_ENV"
  build_with_autotools "expat" "$prereq_build" "$_CROSS_VERSION_EXPAT" "$_CROSS_LOG_DIR/$host" \
                        "$expatconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  case $host in
    *-*-mingw32|*-*-cygwin)
      fetch_source_release "$_CROSS_URL_GNU/libiconv" "libiconv-$_CROSS_VERSION_LIBICONV" "gz"
      libiconvconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                             --disable-shared --enable-static \
                             $_CROSS_MULTILIB_ENV"
      build_with_autotools "libiconv" "$prereq_build" "$_CROSS_VERSION_LIBICONV" "$_CROSS_LOG_DIR/$host" \
                           "$libiconvconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  esac
)
