#! /usr/bin/env sh

build_mingw_toolchain()
(
  host="$1"
  shortname="$2"
  builddir="$3"
  abisuffix="$4"
  prereqabisuffix="$5"

  # Compiler settings
  #TODO make selectable and working: winpthreads build complains that it can't link to -lpthread :-(
  gccabioptions="--enable-threads=posix"
  case "$shortname" in
    mingw32)
      printf "> Building compiler targetting 32-bit Windows.\n"
      target="i686-w64-mingw32"
      mingww64crtoptions="--enable-lib32 --disable-lib64"
      #gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions"
      ;;
    mingw32-dw2)
      printf "> Building compiler targetting 32-bit Windows (dw2).\n"
      target="i686-w64-mingw32"
      mingww64crtoptions="--enable-lib32 --disable-lib64"
      gccabioptions="$gccabioptions --enable-dw2-exceptions --disable-sjlj-exceptions" ;;
    mingw64)
      printf "> Building compiler targetting 64-bit Windows.\n"
      target="x86_64-w64-mingw32"
      mingww64crtoptions="--disable-lib32 --enable-lib64"
      #gccabioptions="$gccabioptions --enable-seh-exceptions --disable-sjlj-exceptions"
      ;;
    mingw64-sjlj)
      printf "> Building compiler targetting 64-bit Windows (sjlj).\n"
      target="x86_64-w64-mingw32"
      mingww64crtoptions="--disable-lib32 --enable-lib64"
      gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
    *)
      printf "Invalid shortname \'$shortname\' passed to build_mingw_toolchain.\n";
      exit 1;
  esac

  case $host in
    *-*-mingw32)
      gnu_win32_options="--disable-win32-registry --disable-rpath --disable-werror --with-libiconv-prefix=$_CROSS_STAGE_DIR"
      if [ "$host" = "$target" ]
      then
        binutilstooldir="tooldir=$_CROSS_STAGE_DIR/$shortname"
      fi
      ;;
    *)
      gnu_win32_options=
  esac

  if [ "$host" = "$_CROSS_BUILD" ]
  then
    PATH="$_CROSS_STAGE_DIR/$shortname/bin:$PATH"
  fi

  case "$_CROSS_VERSION_GCC" in
    4.[6-7]*)
      pploptions="--with-ppl=$_CROSS_STAGE_DIR --disable-ppl-version-check \
                  --with-host-libstdcxx='-lstdc++ -lm -gcc_eh'"
  esac
  gcclanguages="--enable-languages=c,lto,c++,objc,obj-c++,fortran,java,ada"
  gccconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                    --with-sysroot=$_CROSS_STAGE_DIR/$shortname --prefix=$_CROSS_STAGE_DIR/$shortname \
                    --with-gmp=$_CROSS_STAGE_DIR --with-mpfr=$_CROSS_STAGE_DIR --with-mpc=$_CROSS_STAGE_DIR \
                    --with-cloog=$_CROSS_STAGE_DIR --disable-cloog-version-check \
                    --enable-cloog-backend=isl --with-isl=$_CROSS_STAGE_DIR --disable-isl-version-check \
                    $pploptions \
                    --enable-shared --enable-static --enable-plugins \
                    --disable-multilib --enable-libgomp --disable-libstdcxx-pch \
                    $gccabioptions \
                    \
                    --enable-fully-dynamic-string --enable-libstdcxx-time \
                    --disable-nls --disable-werror --enable-checking=release \
                    --with-gnu-as --with-gnu-ld \
                    $gnu_win32_options $_CROSS_GNU_PKGVERSION \
                    $_CROSS_MULTILIB_ENV \
                    LDFLAGS=-static"

  # package extensions
  ext=$(package_ext $host)
  targetext=$(package_ext $target)

  # prepare MinGW-w64
  fetch_source_release "$_CROSS_URL_MINGW_W64" "mingw-w64-$_CROSS_VERSION_MINGW_W64" "bz2" || exit 1
  if [ -h "$_CROSS_SOURCE_DIR/mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" ]
  then
    printf ">>> MinGW-w64 source symlinks exist.\n"
  else
    ln -s "$_CROSS_SOURCE_DIR/mingw-w64-$_CROSS_VERSION_MINGW_W64/mingw-w64-headers" "$_CROSS_SOURCE_DIR/mingw-w64-headers-$_CROSS_VERSION_MINGW_W64"
    ln -s "$_CROSS_SOURCE_DIR/mingw-w64-$_CROSS_VERSION_MINGW_W64/mingw-w64-crt" "$_CROSS_SOURCE_DIR/mingw-w64-crt-$_CROSS_VERSION_MINGW_W64"
    ln -s "$_CROSS_SOURCE_DIR/mingw-w64-$_CROSS_VERSION_MINGW_W64/mingw-w64-libraries/winpthreads" "$_CROSS_SOURCE_DIR/mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64"
  fi

## MinGW-w64 headers
  if [ -f "$_CROSS_PACKAGE_DIR/$target-mingw-w64-headers-$_CROSS_VERSION_MINGW_W64$targetext" ]
  then
    printf ">> Found mingw-w64-headers-$_CROSS_VERSION_MINGW_W64 package.\n"
  else
    mingw_w64headersconfigureargs="--host=$target --build=$_CROSS_BUILD --target=$target \
                                   --prefix=/$target \
                                   --enable-sdk=all --enable-secure-api"
    build_with_autotools "mingw-w64-headers" "$builddir" "$_CROSS_VERSION_MINGW_W64" "$target" \
                         "$mingw_w64headersconfigureargs" "$_CROSS_MAKE_ARGS" "install" || exit 1
    copy_licenses "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" "../COPYING.MinGW-w64/COPYING.MinGW-w64.txt \
                                                                 ../COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt \
                                                                 ../COPYING \
                                                                 ../DISCLAIMER \
                                                                 ../DISCLAIMER.PD \
                                                                 ddk/readme.txt \
                                                                 direct-x/COPYING.LIB \
                                                                 direct-x/readme.txt" || exit 1
    package "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" || exit 1
  fi

## Binutils
  if [ -f "$_CROSS_PACKAGE_DIR/${host}_$target-binutils-$_CROSS_VERSION_BINUTILS$ext" ]
  then
    printf ">> Found binutils-$_CROSS_VERSION_BINUTILS package.\n"
  else
    fetch_source_release "$_CROSS_URL_GNU/binutils" "binutils-$_CROSS_VERSION_BINUTILS" "bz2" || exit 1
    binutilsconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                           --with-sysroot=$_CROSS_STAGE_DIR/$shortname --prefix=$_CROSS_STAGE_DIR/$shortname \
                           --enable-64-bit-bfd --disable-multilib --disable-nls --disable-werror \
                           $gnu_win32_options $_CROSS_PACKAGE_VERSION \
                           $_CROSS_MULTILIB_ENV"
                           #CC=$host-gcc
    build_with_autotools "binutils" "$builddir" "$_CROSS_VERSION_BINUTILS" "${host}_$target" \
                         "$binutilsconfigureargs" "$_CROSS_MAKE_ARGS $binutilstooldir" "install-strip $binutilstooldir" || exit 1
    mv "$_CROSS_STAGE_INSTALL_DIR$_CROSS_STAGE_DIR/$shortname"/* "$_CROSS_STAGE_INSTALL_DIR/"
    if [ "$host" = "$target" ]
    then
      rm -f "$_CROSS_STAGE_INSTALL_DIR/lib/lib"*.a "$_CROSS_STAGE_INSTALL_DIR/include/"*.h
    fi
    copy_licenses "binutils-$_CROSS_VERSION_BINUTILS" "COPYING COPYING.LIB COPYING3 COPYING3.LIB" || exit 1
    package "${host}_$target" "binutils-$_CROSS_VERSION_BINUTILS" || exit 1
  fi

## GCC - bootstrap
  if [ -f "$_CROSS_PACKAGE_DIR/${host}_$target-gcc-$_CROSS_VERSION_GCC$abisuffix-bootstrap$ext" ]
  then
    printf ">> Found gcc-$_CROSS_VERSION_GCC$abisuffix-bootstrap package.\n"
  else
    fetch_source_release "$_CROSS_URL_GNU/gcc/gcc-$_CROSS_VERSION_GCC" "gcc-$_CROSS_VERSION_GCC" "bz2" "$_CROSS_PATCHES_GCC" || exit 1

    stage_projects "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
    if [ "$host" = "$_CROSS_BUILD" ]
    then
      stage_projects "${host}_$target" "binutils-$_CROSS_VERSION_BINUTILS"|| exit 1
    fi
    stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$prereqabisuffix \
                            mpfr-$_CROSS_VERSION_MPFR \
                            mpc-$_CROSS_VERSION_MPC \
                            isl-$_CROSS_VERSION_ISL \
                            cloog-$_CROSS_VERSION_CLOOG" || exit 1
    case "$_CROSS_VERSION_GCC" in
      4.[6-7]*)
        stage_projects "$host" "ppl-$_CROSS_VERSION_PPL$prereqabisuffix" || exit 1
    esac
    mkdir -p $_CROSS_STAGE_DIR/$shortname/mingw/include
    build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "${host}_$target" \
                         "$gccconfigureargs --enable-languages=c,c++,lto" "$_CROSS_MAKE_ARGS all-gcc" "install-strip-gcc" "$abisuffix-bootstrap" || exit 1

    mv "$_CROSS_STAGE_INSTALL_DIR$_CROSS_STAGE_DIR/$shortname"/* "$_CROSS_STAGE_INSTALL_DIR/"
    copy_licenses "gcc-$_CROSS_VERSION_GCC" "COPYING COPYING.LIB COPYING.RUNTIME COPYING3 COPYING3.LIB" || exit 1
    package "${host}_$target" "gcc-$_CROSS_VERSION_GCC$abisuffix-bootstrap" || exit 1
  fi

## MinGW-w64 CRT
  if [ -f "$_CROSS_PACKAGE_DIR/$target-mingw-w64-crt-$_CROSS_VERSION_MINGW_W64$targetext" ]
  then
    printf ">> Found mingw-w64-crt-$_CROSS_VERSION_MINGW_W64 package.\n"
  else
    mingw_w64crtconfigureargs="--host=$target --build=$_CROSS_BUILD --target=$target \
                               --prefix=/$target \
                               --enable-wildcard $mingww64crtoptions"
    if [ "$host" = "$_CROSS_BUILD" ]
    then
      stage_projects "${host}_$target" "gcc-$_CROSS_VERSION_GCC$abisuffix-bootstrap \
                                        binutils-$_CROSS_VERSION_BINUTILS" "$shortname" || exit 1
    fi
    stage_projects "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
    build_with_autotools "mingw-w64-crt" "$builddir" "$_CROSS_VERSION_MINGW_W64" "$target" \
                         "$mingw_w64crtconfigureargs" "$_CROSS_MAKE_ARGS" "install" || exit 1
    copy_licenses "mingw-w64-crt-$_CROSS_VERSION_MINGW_W64" "../COPYING.MinGW-w64/COPYING.MinGW-w64.txt \
                                                             ../COPYING.MinGW-w64-runtime/COPYING.MinGW-w64-runtime.txt \
                                                             ../COPYING \
                                                             ../DISCLAIMER \
                                                             ../DISCLAIMER.PD" || exit 1
    package "$target" "mingw-w64-crt-$_CROSS_VERSION_MINGW_W64" || exit 1
  fi

## MinGW-w64 winpthreads
  if [ -f "$_CROSS_PACKAGE_DIR/${host}_$target-mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64$ext" ]
  then
    printf ">> Found mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64 package.\n"
  else
    winpthreadsconfigureargs="--host=$target --build=$_CROSS_BUILD \
                              --prefix=/$target \
                              --enable-shared --enable-static"
    if [ "$host" = "$_CROSS_BUILD" ]
    then
      stage_projects "${host}_$target" "gcc-$_CROSS_VERSION_GCC$abisuffix-bootstrap \
                                        binutils-$_CROSS_VERSION_BINUTILS" "$shortname" || exit 1
    fi
    stage_projects "$target" "mingw-w64-crt-$_CROSS_VERSION_MINGW_W64 \
                              mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
    # create dummy libpthread, here a copy of another lib
    if [ ! -f "$_CROSS_STAGE_DIR/$target/libpthread.a" ]
    then
      cp "$_CROSS_STAGE_DIR/$shortname/$target/lib/libuser32.a" "$_CROSS_STAGE_DIR/$shortname/$target/lib/libpthread.a"
    fi
    build_with_autotools "mingw-w64-winpthreads" "$builddir" "$_CROSS_VERSION_MINGW_W64" "${host}_$target" \
                         "$winpthreadsconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1

    if [ "$host" = "$target" ]
    then
      case "$host" in
        *-w64-mingw32)
          mkdir -p "$_CROSS_STAGE_INSTALL_DIR/bin"
          mv "$_CROSS_STAGE_INSTALL_DIR/$target/bin/libwinpthread-1.dll" "$_CROSS_STAGE_INSTALL_DIR/bin/" || exit 1
      esac
    else
      mv "$_CROSS_STAGE_INSTALL_DIR/$target/bin/libwinpthread-1.dll" "$_CROSS_STAGE_INSTALL_DIR/$target/lib/" || exit 1
      rmdir "$_CROSS_STAGE_INSTALL_DIR/$target/bin/" || exit 1
    fi
    copy_licenses "mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64" "COPYING" || exit 1
    package "${host}_$target" "mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64" || exit 1
  fi

## GCC
  if [ -f "$_CROSS_PACKAGE_DIR/${host}_$target-gcc-$_CROSS_VERSION_GCC$abisuffix$ext" ]
  then
    printf ">> Found gcc-$_CROSS_VERSION_GCC$abisuffix package.\n"
  else
    stage_projects "$host" "gmp-$_CROSS_VERSION_GMP$prereqabisuffix \
                            mpfr-$_CROSS_VERSION_MPFR \
                            mpc-$_CROSS_VERSION_MPC \
                            isl-$_CROSS_VERSION_ISL \
                            cloog-$_CROSS_VERSION_CLOOG" || exit 1
    case "$_CROSS_VERSION_GCC" in
      4.[6-7]*)
        stage_projects "$host" "ppl-$_CROSS_VERSION_PPL$prereqabisuffix" || exit 1
    esac
    if [ "$host" = "$_CROSS_BUILD" ]
    then
      stage_projects "${host}_$target" "binutils-$_CROSS_VERSION_BINUTILS" "$shortname" || exit 1
    fi
    stage_projects "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64 \
                              mingw-w64-crt-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
    stage_projects "${host}_$target" "mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
    mkdir -p "$_CROSS_STAGE_DIR/$shortname/mingw/include"

    build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "${host}_$target" \
                         "$gccconfigureargs $gcclanguages" "$_CROSS_MAKE_ARGS" "install-strip" "$abisuffix" || exit 1
    mv "$_CROSS_STAGE_INSTALL_DIR$_CROSS_STAGE_DIR/$shortname"/* "$_CROSS_STAGE_INSTALL_DIR/"
    case "$host-$target" in
      *-*-mingw32-*-*-mingw32)
        printf ">>> Fixing libgcc DLL location.\n"
        if [ -f "$_CROSS_STAGE_INSTALL_DIR/lib/libgcc_s_sjlj-1.dll" ]
        then
          mv "$_CROSS_STAGE_INSTALL_DIR/lib/libgcc_s_sjlj-1.dll" "$_CROSS_STAGE_INSTALL_DIR/bin/" || exit 1
        elif [ -f "$_CROSS_STAGE_INSTALL_DIR/lib/libgcc_s_dw2-1.dll" ]
        then
          mv "$_CROSS_STAGE_INSTALL_DIR/lib/libgcc_s_dw2-1.dll" "$_CROSS_STAGE_INSTALL_DIR/bin/" || exit 1
        elif [ -f "$_CROSS_STAGE_INSTALL_DIR/lib/libgcc_s_seh-1.dll" ]
        then
          mv "$_CROSS_STAGE_INSTALL_DIR/lib/libgcc_s_seh-1.dll" "$_CROSS_STAGE_INSTALL_DIR/bin/" || exit 1
        fi
    esac
    rm -f "$_CROSS_STAGE_INSTALL_DIR/lib/libiberty.a"
    rm -rf "$_CROSS_STAGE_INSTALL_DIR/mingw"
    copy_licenses "gcc-$_CROSS_VERSION_GCC" "COPYING COPYING.LIB COPYING.RUNTIME COPYING3 COPYING3.LIB" || exit 1
    package "${host}_$target" "gcc-$_CROSS_VERSION_GCC$abisuffix" || exit 1
  fi

  if [ -f "$_CROSS_PACKAGE_DIR/${host}_$target-gdb-$_CROSS_VERSION_GDB$ext" ]
  then
    printf ">> Found gdb-$_CROSS_VERSION_GDB package.\n"
  else
    fetch_source_release "$_CROSS_URL_GNU/gdb" "gdb-$_CROSS_VERSION_GDB" "bz2" || exit 1
    case "$host" in
      *-mingw32)
        if [ ! -h "$_CROSS_PACKAGE_DIR/$host-python-$_CROSS_VERSION_PYTHON$ext" ]
        then
          ln -s "$_CROSS_DIR/$host-python-$_CROSS_VERSION_PYTHON$ext" "$_CROSS_PACKAGE_DIR"
        fi
        stage_projects "$host" "python-$_CROSS_VERSION_PYTHON" "python" || exit 1
        if [ "$host" = "x86_64-w64-mingw32" ]
        then
          pythongdbcppflags="CFLAGS='-I"$_CROSS_STAGE_DIR"/python/include -DMS_WIN64'"
        else
          pythongdbcppflags="CFLAGS=-I$_CROSS_STAGE_DIR/python/include"
        fi
        pythongdbldflags="LDFLAGS='-static -L"$_CROSS_STAGE_DIR/python"'"
    esac
    gdbconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                      --prefix=/ \
                      --enable-static --disable-shared \
                      --with-libexpat-prefix=$_CROSS_STAGE_DIR \
                      --disable-multilib --enable-64-bit-bfd --disable-nls \
                      --with-python $pythongdbcppflags $pythongdbldflags \
                      $gnu_win32_options $_CROSS_GNU_PKG_VERSION"
    stage_projects "$host" "expat-$_CROSS_VERSION_EXPAT" || exit 1
    build_with_autotools "gdb" "$builddir" "$_CROSS_VERSION_GDB" "${host}_$target" \
                         "$gdbconfigureargs" "$_CROSS_MAKE_ARGS" "install INSTALL_PROGRAM='install -s'" || exit 1
    rm -f "$_CROSS_STAGE_INSTALL_DIR/lib/"*.a "$_CROSS_STAGE_INSTALL_DIR/include/"*.h
    case "$host" in
      *-mingw32)
        stage_projects "$host" "python-$_CROSS_VERSION_PYTHON" "python" || exit 1
        mkdir -p "$_CROSS_STAGE_INSTALL_DIR/bin/"
        cp "$_CROSS_STAGE_DIR/python/python27.dll" "$_CROSS_STAGE_INSTALL_DIR/bin/"
        cp -r "$_CROSS_STAGE_DIR/python/lib" "$_CROSS_STAGE_INSTALL_DIR/bin/"
    esac
    rm -rf "$_CROSS_STAGE_INSTALL_DIR/include/gdb"
    copy_licenses "gdb-$_CROSS_VERSION_GDB" "COPYING COPYING.LIB COPYING3 COPYING3.LIB" || exit 1
    package "${host}_$target" "gdb-$_CROSS_VERSION_GDB" || exit 1
  fi

  case "$host" in
    *-mingw32)
      if [ -f "$_CROSS_PACKAGE_DIR/$host-make-$_CROSS_VERSION_MAKE$ext" ]
      then
        printf ">> Found make-$_CROSS_VERSION_MAKE package.\n"
      else
        fetch_source_release "$_CROSS_URL_GNU/make" "make-$_CROSS_VERSION_MAKE" "bz2" "$_CROSS_PATCHES_MAKE" || exit 1
        makeconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=/ \
                           --enable-job-server --without-guile \
                           --enable-case-insensitive-file-system --program-prefix='mingw32-' \
                           LDFLAGS=-static \
                           $gnu_win32_options"
        build_with_autotools "make" "$builddir" "$_CROSS_VERSION_MAKE" "$host" \
                             "$makeconfigureargs" "$_CROSS_MAKE_ARGS" || exit 1
        rm -f "$_CROSS_STAGE_INSTALL_DIR/include/gnumake.h"
        copy_licenses "make-$_CROSS_VERSION_MAKE" "COPYING" || exit 1
        package "$host" "make-$_CROSS_VERSION_MAKE" || exit 1
      fi
  esac
)
