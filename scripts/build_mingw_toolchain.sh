#! /usr/bin/env sh

build_mingw_toolchain()
(
  host="$1"
  shortname="$2"
  builddir="$3"
  
  # Compiler settings
  #TODO make selectable and working: winpthreads build complains that it can't link to -lpthread :-(
  gccabioptions="--enable-threads=posix"
  case "$shortname" in
    mingw32)
      printf "> Building compiler targetting 32-bit Windows.\n"
      target="i686-w64-mingw32"
      gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
    mingw32-dw2)
      printf "> Building compiler targetting 32-bit Windows (dw2).\n"
      target="i686-w64-mingw32"
      gccabioptions="$gccabioptions --enable-dw2-exceptions --disable-sjlj-exceptions" ;;
    mingw64)
      printf "> Building compiler targetting 64-bit Windows.\n"
      target="x86_64-w64-mingw32"
      gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
    mingw64-sjlj)
      printf "> Building compiler targetting 64-bit Windows (sjlj).\n"
      target="x86_64-w64-mingw32"
      gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
    *)
      printf "Invalid shortname \'$shortname\' passed to build_mingw_toolchain.\n";
      exit 1;
  esac
  
  # MinGW-w64 v3+ changed install prefix meaning
  case "$_CROSS_VERSION_MINGW_W64" in
    trunk|v3.*)
      mingw_w64prefix="$prefix/$target" ;;
    v1.*|v2.*)
      mingw_w64prefix="$prefix/" ;;
    *)
      printf "Error: unknown MinGW-w64 version: $_CROSS_VERSION_MINGW_W64. Check versions.sh.\n"
      exit 1 ;;
  esac

  case $host in
    *-*-mingw32)
      gnu_win32_options="--disable-win32-registry --disable-rpath --disable-werror --with-libiconv-prefix=$prereq_install" ;;
    *)
      gnu_win32_options= ;;
  esac
  
  # prepare MinGW-w64
  fetch_source_release "$_CROSS_URL_MINGW_W64" "mingw-w64-$_CROSS_VERSION_MINGW_W64" "bz2" || exit 1
  ln -s "$_CROSS_SOURCE_DIR/mingw-w64-$_CROSS_VERSION_MINGW_W64/mingw-w64-headers" "$_CROSS_SOURCE_DIR/mingw-w64-headers-$_CROSS_VERSION_MINGW_W64"
  ln -s "$_CROSS_SOURCE_DIR/mingw-w64-$_CROSS_VERSION_MINGW_W64/mingw-w64-crt" "$_CROSS_SOURCE_DIR/mingw-w64-crt-$_CROSS_VERSION_MINGW_W64"
  ln -s "$_CROSS_SOURCE_DIR/mingw-w64-$_CROSS_VERSION_MINGW_W64/mingw-w64-libraries/winpthreads" "$_CROSS_SOURCE_DIR/mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64"
  
  # MinGW-w64 headers
  mingw_w64headersconfigureargs="--host=$target --build=$_CROSS_BUILD --target=$target \
                                 --prefix=$mingw_w64prefix --enable-sdk=all --enable-secure-api"
  build_with_autotools "mingw-w64-headers" "$builddir" "$_CROSS_VERSION_MINGW_W64" "$target" \
                       "$mingw_w64headersconfigureargs" "$_CROSS_MAKE_ARGS" "install" || exit 1
  
  # Binutils
  fetch_source_release "$_CROSS_URL_GNU/binutils" "binutils-$_CROSS_VERSION_BINUTILS" "bz2" || exit 1
  binutilsconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                         --with-sysroot=/$shortname --prefix=/$shortname \
                         --enable-64-bit-bfd --disable-multilib --disable-nls --disable-werror \
                         $gnu_win32_options \
                         $_CROSS_PACKAGE_VERSION"
                         #CC=$host-gcc
  build_with_autotools "binutils" "$builddir" "$_CROSS_VERSION_BINUTILS" "$host_$target" \
                       "$binutilsconfigureargs" "$_CROSS_MAKE_ARGS tooldir=$prefix" || exit 1
  rm -rf "$_CROSS_SOURCE_DIR/binutils-$_CROSS_VERSION_PPL"

  echo "$_CROSS_PATCHES_GCC"
  fetch_source_release "$_CROSS_URL_GNU/gcc/gcc-$_CROSS_VERSION_GCC" "gcc-$_CROSS_VERSION_GCC" "bz2" "$_CROSS_PATCHES_GCC" || exit 1
  case "$_CROSS_VERSION_GCC" in
    4.[5-7]*)
      pploptions="--with-ppl=$_CROSS_STAGE_DIR --disable-ppl-version-check \
                  --with-host-libstdcxx='-lstdc++ -lm -gcc_eh'" ;;
  esac
  gccconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                    --with-sysroot=/$shortname --prefix=/$shortname \
                    --with-gmp=$_CROSS_STAGE_DIR --with-mpfr=$_CROSS_STAGE_DIR --with-mpc=$_CROSS_STAGE_DIR \
                    --with-cloog=$_CROSS_STAGE_DIR --disable-cloog-version-check \
                    --enable-cloog-backend=isl --with-isl=$_CROSS_STAGE_DIR \
                    $pploptions \
                    --enable-shared --enable-static --enable-plugins \
                    --disable-multilib --enable-libgomp --disable-libstdcxx-pch \
                    $gccabioptions \
                    --enable-languages=c,lto,c++,objc,obj-c++,fortran,java \
                    --enable-fully-dynamic-string --enable-libstdcxx-time \
                    --disable-nls --disable-werror --enable-checking=release \
                    --with-gnu-as --with-gnu-ld \
                    $gnu_win32_options $_CROSS_GNU_PKGVERSION \
                    LDFLAGS=-static"
  stage_project "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" || exit 1
  stage_project "$host" "gmp-$_CROSS_VERSION_GMP" || exit 1
  stage_project "$host" "mpfr-$_CROSS_VERSION_MPFR" || exit 1
  stage_project "$host" "mpc-$_CROSS_VERSION_MPC" || exit 1
  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      stage_project "$host" "ppl-$_CROSS_VERSION_PPL" || exit 1 ;;
  esac
  stage_project "$host" "isl-$_CROSS_VERSION_ISL" || exit 1
  stage_project "$host" "cloog-$_CROSS_VERSION_CLOOG" || exit 1
  mkdir -p $_CROSS_STAGE_DIR/mingw/include
  build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "$host_$target" \
                       "$gccconfigureargs" "$_CROSS_MAKE_ARGS all-gcc" "install-gcc" "-bootstrap" || exit 1
  
  mingw_w64crtconfigureargs="--host=$target --build=$_CROSS_BUILD --target=$target \
                             --prefix=$mingw_w64prefix --enable-sdk=all --enable-wildcard"
  stage_project "$host_$target" "gcc-$_CROSS_VERSION_GCC-bootstrap" || exit 1
  build_with_autotools "mingw-w64-crt" "$builddir" "$_CROSS_VERSION_MINGW_W64" "$target" \
                       "$mingw_w64crtconfigureargs" "$_CROSS_MAKE_ARGS" "install" || exit 1
  
  # create dummy libpthread, here a copy of another lib
  if [ ! -f "$_CROSS_STAGE_DIR/$target/libpthread.a" ]
  then
    cp "$prefix/$target/lib/libuser32.a" "$prefix/$target/lib/libpthread.a"
  fi
  
  winpthreadsconfigureargs="--host=$target --build=$_CROSS_BUILD \
                            --prefix=$prefix/$target \
                            --enable-shared --enable-static"
  build_with_autotools "mingw-w64" "$builddir" "$_CROSS_VERSION_MINGW_W64/mingw-w64-winpthreads" "$_CROSS_LOG_DIR/$host/$target" \
                       "$winpthreadsconfigureargs" "$_CROSS_MAKE_ARGS" "install-strip" "-winpthreads" || exit 1
  
#   case "$_CROSS_VERSION_GCC" in
#     4.[6-7]*)
#       rm -rf $builddir/gcc
#   esac
  build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "$_CROSS_LOG_DIR/$host/$target" \
                       "$gccconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
  rm -rf "$_CROSS_SOURCE_DIR"/*
)
