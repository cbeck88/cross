#! /usr/bin/env sh

build_mingw_toolchain()
(
  host="$1"
  shortname="$2"
  builddir="$3"
  prefix="$4"
  prereq_install="$5"
  mingw_w64prefix="$6"
  
  # Compiler settings
  #TODO make selectable and working: winpthreads build complains that it can't link to -lpthread :-(
  gccabioptions="--enable-threads=posix"
  case "$shortname" in
    mingw32)
      printf "> Building compiler for 32-bit Windows.\n"
      target="i686-w64-mingw32"
      gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
    mingw32-dw2)
      printf "> Building compiler for 32-bit Windows (dw2).\n"
      target="i686-w64-mingw32"
      gccabioptions="$gccabioptions --enable-dw2-exceptions --disable-sjlj-exceptions" ;;
    mingw64)
      printf "> Building compiler for 64-bit Windows.\n"
      target="x86_64-w64-mingw32"
      case $_CROSS_GCC_VERSION in
        4.[5-7]*)
          gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
        *)
          # messes up GCC 4.8.2 configure so that it complains dw2 EH is not available for some reason.
          #gccabioptions="$gccabioptions --disable-sjlj-exceptions --disable-dw2-exceptions --enable-seh-exceptions"
          ;;
      esac ;;
    *)
      printf "Invalid shortname \'$shortname\' passed to build_crosscompiler.\n"; exit 1; ;;
  esac
  
  # MinGW-w64 v3+ changed install prefix meaning
  case "$_CROSS_VERSION_MINGW_W64" in
    trunk|v3.*)
      mingw_w64prefix="$prefix/$target" ;;
    v1.*|v2.*)
      mingw_w64prefix="$prefix" ;;
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
  
  # mingw-w64 headers
  mingw_w64headersconfigureargs="--host=$target --build=$_CROSS_BUILD --target=$target \
                                 --prefix=$mingw_w64prefix --enable-sdk=all --enable-secure-api"
  build_with_autotools "mingw-w64" "$builddir/mingw-w64-headers" "$_CROSS_VERSION_MINGW_W64/mingw-w64-headers" "$_CROSS_LOG_DIR/$host/$target" \
                       "$mingw_w64headersconfigureargs" "$_CROSS_MAKE_ARGS" "install" "-headers"
  
  # Binutils
  binutilsconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                         --with-sysroot=$prefix --prefix=$prefix \
                         --enable-64-bit-bfd --disable-multilib --disable-nls --disable-werror \
                         $gnu_win32_options \
                         $_CROSS_PACKAGE_VERSION"
                         #CC=$host-gcc
  build_with_autotools "binutils" "$builddir" "$_CROSS_VERSION_BINUTILS" "$_CROSS_LOG_DIR/$host/$target" \
                       "$binutilsconfigureargs" "$_CROSS_MAKE_ARGS tooldir=$prefix"
  case "$_CROSS_VERSION_GCC" in
    4.5*|4.6*|4.7*)
      pploptions="--with-ppl=$prereq_install --disable-ppl-version-check \
                  --with-host-libstdcxx='-lstdc++ -lm -gcc_eh'" ;;
  esac
  gccconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                    --with-sysroot=$prefix --prefix=$prefix \
                    --with-gmp=$prereq_install --with-mpfr=$prereq_install --with-mpc=$prereq_install \
                    --with-cloog=$prereq_install --disable-cloog-version-check \
                    --enable-cloog-backend=isl --with-isl=$prereq_install \
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
  build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "$_CROSS_LOG_DIR/$host/$target" \
                       "$gccconfigureargs" "$_CROSS_MAKE_ARGS all-gcc" "install-gcc" "-bootstrap"
  
  mingw_w64crtconfigureargs="--host=$target --build=$_CROSS_BUILD --target=$target \
                             --prefix=$mingw_w64prefix --enable-sdk=all --enable-wildcard"
  build_with_autotools "mingw-w64" "$builddir/mingw-w64-crt" "$_CROSS_VERSION_MINGW_W64/mingw-w64-crt" "$_CROSS_LOG_DIR/$host/$target" \
                       "$mingw_w64crtconfigureargs" "$_CROSS_MAKE_ARGS" "install" "-crt"
  
  # create dummy libpthread, here a copy of another lib
  if [ ! -f "$prefix/$target/libpthread.a" ]
  then
    cp "$prefix/$target/lib/libuser32.a" "$prefix/$target/lib/libpthread.a"
  fi
  
  winpthreadsconfigureargs="--host=$target --build=$_CROSS_BUILD \
                            --prefix=$prefix/$target \
                            --enable-shared --enable-static"
  build_with_autotools "mingw-w64" "$builddir/winpthreads" "$_CROSS_VERSION_MINGW_W64/mingw-w64-libraries/winpthreads" "$_CROSS_LOG_DIR/$host/$target" \
                       "$winpthreadsconfigureargs" "$_CROSS_MAKE_ARGS" "install" "-winpthreads"
  
  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      rm -rf $builddir/gcc
  esac
  build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "$_CROSS_LOG_DIR/$host/$target" \
                       "$gccconfigureargs" "$_CROSS_MAKE_ARGS"
)
