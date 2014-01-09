#! /usr/bin/env sh

build_gnu_prerequisites()
(
  host="$1"

  # Directories
  mkdir -p "$_CROSS_LOG_DIR/prereq-$host"
  prereq_build="$_CROSS_BUILD_DIR/prereq-$_CROSS_VERSION_GCC-$host"
  mkdir -p "$prereq_build" && cd "$prereq_build"

  fetch_source_release "$_CROSS_URL_GNU/gmp" "gmp-$_CROSS_VERSION_GMP" "bz2" || exit 1
  gmpconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                    --disable-shared --enable-static \
                    --enable-cxx \
                    $_CROSS_MULTILIB_ENV"
  build_with_autotools "gmp" "$prereq_build" "$_CROSS_VERSION_GMP" "$host" \
                      "$gmpconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  
  fetch_source_release "$_CROSS_URL_GNU/mpfr" "mpfr-$_CROSS_VERSION_MPFR" "xz" "$_CROSS_PATCHES_MPFR"  || exit 1
  mpfrconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                     --disable-shared --enable-static \
                     --with-gmp=$_CROSS_STAGE_DIR \
                     $_CROSS_MULTILIB_ENV"
  stage_project "$host" "gmp-$_CROSS_VERSION_GMP" || exit 1
  build_with_autotools "mpfr" "$prereq_build" "$_CROSS_VERSION_MPFR" "$host" \
                      "$mpfrconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  rm -rf "$_CROSS_STAGE_DIR"
  
  fetch_source_release "$_CROSS_URL_GNU/mpc" "mpc-$_CROSS_VERSION_MPC" "gz" || exit 1
  mpcconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                    --disable-shared --enable-static \
                    --with-gmp=$_CROSS_STAGE_DIR --with-mpfr=$_CROSS_STAGE_DIR \
                    $_CROSS_MULTILIB_ENV"
  stage_project "$host" "gmp-$_CROSS_VERSION_GMP" || exit 1
  stage_project "$host" "mpfr-$_CROSS_VERSION_MPFR" || exit 1
  build_with_autotools "mpc" "$prereq_build" "$_CROSS_VERSION_MPC" "$host" \
                      "$mpcconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  rm -rf "$_CROSS_STAGE_DIR"
  
  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      fetch_source_release "$_CROSS_URL_PPL" "ppl-$_CROSS_VERSION_PPL" "gz" || exit 1
      pplconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                        --disable-shared --enable-static \
                        --with-gmp=$_CROSS_STAGE_DIR \
                        $_CROSS_MULTILIB_ENV"
      stage_project "$host" "gmp-$_CROSS_VERSION_GMP" || exit 1
      build_with_autotools "ppl" "$prereq_build" "$_CROSS_VERSION_PPL" "$host" \
                           "$pplconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
      rm -rf "$_CROSS_STAGE_DIR"
  esac
  
  fetch_source_release "$_CROSS_URL_ISL" "isl-$_CROSS_VERSION_ISL" "bz2" || exit 1
  islconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                    --disable-shared --enable-static \
                    --with-gmp-prefix=$_CROSS_STAGE_DIR \
                    $_CROSS_MULTILIB_ENV"
  stage_project "$host" "gmp-$_CROSS_VERSION_GMP" || exit 1
  build_with_autotools "isl" "$prereq_build" "$_CROSS_VERSION_ISL" "$host" \
                        "$islconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  rm -rf "$_CROSS_STAGE_DIR"
  
  fetch_source_release "$_CROSS_URL_CLOOG" "cloog-$_CROSS_VERSION_CLOOG" "gz" || exit 1
  cloogconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                      --disable-shared --enable-static \
                      --with-gmp-prefix=$_CROSS_STAGE_DIR --with-bits=gmp --with-isl-prefix=$_CROSS_STAGE_DIR \
                      $_CROSS_MULTILIB_ENV"
  stage_project "$host" "gmp-$_CROSS_VERSION_GMP" || exit 1
  stage_project "$host" "isl-$_CROSS_VERSION_ISL" || exit 1
  build_with_autotools "cloog" "$prereq_build" "$_CROSS_VERSION_CLOOG" "$host" \
                        "$cloogconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  rm -rf "$_CROSS_STAGE_DIR"

  fetch_source_release "$_CROSS_URL_EXPAT" "expat-$_CROSS_VERSION_EXPAT" "gz" || exit 1
  expatconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                      --disable-shared --enable-static \
                      $_CROSS_MULTILIB_ENV"
  build_with_autotools "expat" "$prereq_build" "$_CROSS_VERSION_EXPAT" "$host" \
                        "$expatconfigureargs" "$_CROSS_MAKE_ARGS" "install" || exit 1
  case $host in
    *-*-mingw32|*-*-cygwin)
      fetch_source_release "$_CROSS_URL_GNU/libiconv" "libiconv-$_CROSS_VERSION_LIBICONV" "gz" || exit 1
      libiconvconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                             --disable-shared --enable-static \
                             $_CROSS_MULTILIB_ENV"
      build_with_autotools "libiconv" "$prereq_build" "$_CROSS_VERSION_LIBICONV" "$host" \
                           "$libiconvconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  esac
)
