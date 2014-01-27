#! /usr/bin/env sh

build_gnu_prerequisites()
(
  host="$1"
  abisuffix="$2"
  ext=$(package_ext $host)

  # Directories
  mkdir -p "$_CROSS_LOG_DIR/prereq-$host"
  prereq_build="$_CROSS_BUILD_DIR/prereq-$_CROSS_VERSION_GCC-$host"
  mkdir -p "$prereq_build" && cd "$prereq_build"

  if [ -f "$_CROSS_PACKAGE_DIR/$host-gmp-$_CROSS_VERSION_GMP$abisuffix$ext" ]
  then
    printf ">> Found gmp-$_CROSS_VERSION_GMP$abisuffix package.\n"
  else
    fetch_source_release "$_CROSS_URL_GNU/gmp" "gmp-$_CROSS_VERSION_GMP" "bz2" || exit 1
    gmpconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                      --disable-shared --enable-static \
                      --enable-cxx"
    build_with_autotools "gmp" "$prereq_build" "$_CROSS_VERSION_GMP" "$host" \
                        "$gmpconfigureargs" "$_CROSS_MAKE_ARGS" "install-strip" "$abisuffix" || exit 1
    copy_licenses "gmp-$_CROSS_VERSION_GMP" "COPYING COPYING.LIB" || exit 1
    package "$host" "gmp-$_CROSS_VERSION_GMP" "$abisuffix" || exit 1
  fi

  if [ -f "$_CROSS_PACKAGE_DIR/$host-mpfr-$_CROSS_VERSION_MPFR$ext" ]
  then
    printf ">> Found mpfr-$_CROSS_VERSION_MPFR package.\n"
  else
    fetch_source_release "$_CROSS_URL_GNU/mpfr" "mpfr-$_CROSS_VERSION_MPFR" "xz" "$_CROSS_PATCHES_MPFR"  || exit 1
    mpfrconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                       --disable-shared --enable-static \
                       --with-gmp=$_CROSS_STAGE_DIR"
    stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$abisuffix" || exit 1
    build_with_autotools "mpfr" "$prereq_build" "$_CROSS_VERSION_MPFR" "$host" \
                         "$mpfrconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
    copy_licenses "mpfr-$_CROSS_VERSION_MPFR" "COPYING COPYING.LESSER" || exit 1
    package "$host" "mpfr-$_CROSS_VERSION_MPFR" || exit 1
  fi

  if [ -f "$_CROSS_PACKAGE_DIR/$host-mpc-$_CROSS_VERSION_MPC$ext" ]
  then
    printf ">> Found mpc-$_CROSS_VERSION_MPC package.\n"
  else
    fetch_source_release "$_CROSS_URL_GNU/mpc" "mpc-$_CROSS_VERSION_MPC" "gz" || exit 1
    mpcconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                      --disable-shared --enable-static \
                      --with-gmp=$_CROSS_STAGE_DIR --with-mpfr=$_CROSS_STAGE_DIR"
    stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$abisuffix mpfr-$_CROSS_VERSION_MPFR" || exit 1
    build_with_autotools "mpc" "$prereq_build" "$_CROSS_VERSION_MPC" "$host" \
                         "$mpcconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
    copy_licenses "mpc-$_CROSS_VERSION_MPC" "COPYING.LESSER" || exit 1
    package "$host" "mpc-$_CROSS_VERSION_MPC" || exit 1
  fi

  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      if [ -f "$_CROSS_PACKAGE_DIR/$host-ppl-$_CROSS_VERSION_PPL$abisuffix$ext" ]
      then
        printf ">> Found ppl-$_CROSS_VERSION_PPL$abisuffix package.\n"
      else
        fetch_source_release "$_CROSS_URL_PPL" "ppl-$_CROSS_VERSION_PPL" "gz" || exit 1
        pplconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                          --disable-shared --enable-static \
                          --with-gmp=$_CROSS_STAGE_DIR"
        stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$abisuffix" || exit 1
        build_with_autotools "ppl" "$prereq_build" "$_CROSS_VERSION_PPL" "$host" \
                             "$pplconfigureargs" "$_CROSS_MAKE_ARGS" "install-strip" "$abisuffix" || exit 1
        copy_licenses "ppl-$_CROSS_VERSION_PPL" "COPYING" || exit 1
        package "$host" "ppl-$_CROSS_VERSION_PPL" "$abisuffix" || exit 1
      fi
  esac

  if [ -f "$_CROSS_PACKAGE_DIR/$host-isl-$_CROSS_VERSION_ISL$ext" ]
  then
    printf ">> Found isl-$_CROSS_VERSION_ISL package.\n"
  else
    fetch_source_release "$_CROSS_URL_ISL" "isl-$_CROSS_VERSION_ISL" "bz2" || exit 1
    islconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                      --disable-shared --enable-static \
                      --with-gmp-prefix=$_CROSS_STAGE_DIR"
    stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$abisuffix" || exit 1
    build_with_autotools "isl" "$prereq_build" "$_CROSS_VERSION_ISL" "$host" \
                         "$islconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
    copy_licenses "isl-$_CROSS_VERSION_ISL" "LICENSE" || exit 1
    package "$host" "isl-$_CROSS_VERSION_ISL" || exit 1
  fi

  if [ -f "$_CROSS_PACKAGE_DIR/$host-cloog-$_CROSS_VERSION_CLOOG$ext" ]
  then
    printf ">> Found cloog-$_CROSS_VERSION_CLOOG package.\n"
  else
    fetch_source_release "$_CROSS_URL_CLOOG" "cloog-$_CROSS_VERSION_CLOOG" "gz" || exit 1
    cloogconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                        --disable-shared --enable-static \
                        --with-gmp-prefix=$_CROSS_STAGE_DIR --with-bits=gmp --with-isl-prefix=$_CROSS_STAGE_DIR \
                        $_CROSS_MULTILIB_ENV"
    stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$abisuffix isl-$_CROSS_VERSION_ISL" || exit 1
    build_with_autotools "cloog" "$prereq_build" "$_CROSS_VERSION_CLOOG" "$host" \
                         "$cloogconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
    copy_licenses "cloog-$_CROSS_VERSION_CLOOG" "LICENSE" || exit 1
    package "$host" "cloog-$_CROSS_VERSION_CLOOG" || exit 1
  fi

  if [ -f "$_CROSS_PACKAGE_DIR/$host-expat-$_CROSS_VERSION_EXPAT$ext" ]
  then
    printf ">> Found expat-$_CROSS_VERSION_EXPAT package.\n"
  else
    fetch_source_release "$_CROSS_URL_EXPAT" "expat-$_CROSS_VERSION_EXPAT" "gz" || exit 1
    expatconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                        --disable-shared --enable-static \
                        $_CROSS_MULTILIB_ENV"
    build_with_autotools "expat" "$prereq_build" "$_CROSS_VERSION_EXPAT" "$host" \
                         "$expatconfigureargs" "$_CROSS_MAKE_ARGS" "install" || exit 1
    copy_licenses "expat-$_CROSS_VERSION_EXPAT" "COPYING" || exit 1
    package "$host" "expat-$_CROSS_VERSION_EXPAT" || exit 1
  fi

  case $host in
    *-*-mingw32|*-*-cygwin)
      if [ -f "$_CROSS_PACKAGE_DIR/$host-libiconv-$_CROSS_VERSION_LIBICONV$ext" ]
      then
        printf ">> Found libibconv-$_CROSS_VERSION_LIBICONV package.\n"
      else
        fetch_source_release "$_CROSS_URL_GNU/libiconv" "libiconv-$_CROSS_VERSION_LIBICONV" "gz" || exit 1
        libiconvconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                               --disable-shared --enable-static \
                               $_CROSS_MULTILIB_ENV"
        build_with_autotools "libiconv" "$prereq_build" "$_CROSS_VERSION_LIBICONV" "$host" \
                             "$libiconvconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
        copy_licenses "libiconv-$_CROSS_VERSION_LIBICONV" "COPYING COPYING.LIB" || exit 1
        package "$host" "libiconv-$_CROSS_VERSION_LIBICONV" || exit 1
      fi
  esac
)
