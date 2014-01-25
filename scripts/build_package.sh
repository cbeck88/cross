#! /usr/bin/env sh

## Build steps:
# 1. check built built package.
# 2. 

geturl()
(
  name="$1"
  version="$2"
  
  # generic urls
  gnu="ftp://ftp.nluug.nl/mirror/gnu"
  ppl="ftp://ftp.cs.unipr.it/pub/ppl/releases"
  isl="http://isl.gforge.inria.fr" #"http://isl.gforge.inria.fr" #"ftp://ftp.linux.student.kuleuven.be/pub/people/skimo/isl"
  cloog="http://www.bastoul.net/cloog/pages/download"
  expat="http://sourceforge.net/projects/expat/files/expat"

  mingww64="http://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release"
  mingww64svn="svn://svn.code.sf.net/p/mingw-w64/code"
  
  # extension
  case "$name" in
    gmp|gdb|binutils|gcc|mingw-w64)
      ext=".tar.bz2" ;;
    mpfr)
      ext=".tar.xz" ;;
    mpc|libiconv|ppl)
      ext=".tar.gz"
  esac
  
  # create full URL
  case $name in
    gmp|mpfr|mpc|cloog|libiconv|gdb|binutils|mingw-w64)
      echo "$gnu/$name/$name-$version$ext"
      ;;
    gcc)
      echo "$gnu/$name/$name-$version/$name-$version$ext"
      ;;
    ppl|expat)
      echo "$ppl/$version/$name-$version$ext"
  esac
)

getpatches()
(
  name="$1"
  version="$2"
  
  case "$name" in
    mpfr)
      case "$version" in
        2.4.2)
          echo "mpfr-2.4.2p3"
          ;;
        3.1.2)
          echo "mpfr-3.1.2p5"
      esac ;;
    gcc)
      case "$version" in
      4.6*)
        echo "gcc-4.6-texinfo-5.0 gcc-cloog-LANGUAGE_C gcc-4.6-posix_threads"
        ;;
      4.7.[0-2])
        echo "gcc-4.7-texinfo-5.0 gcc-cloog-LANGUAGE_C gcc-4.7.pre3-segfault gcc-4.7-posix_threads"
        ;;
      4.7*)
        echo "gcc-4.7-posix_threads"
        ;;
      esac ;;
    make)
      echo "make-win32"
  esac
)

configure()
(
  name="$1"
  version="$2"
  host="$3"
  build="$_CROSS_BUILD"
  target="$4"
  srcdir="$_CROSS_SOURCE_DIR/$name-$version"
  stagedir="$_CROSS_STAGE_DIR"
  
  # common stuff
  prereqconfigureargs="--host=$host \
                       --build=$build \
                       --prefix=/ \
                       --disable-shared \
                       --enable-static"
  packageversion="${version}_rubenvb"
  case $host in
    *-mingw32)
      gnu_win32_options="--disable-win32-registry \
                         --disable-rpath \
                         --with-libiconv-prefix=$stagedir"
      if [ "$host" = "$target" ]
      then
        binutilstooldir="tooldir=$_CROSS_STAGE_DIR/$shortname"
      fi
  esac
  
  case $name in
    gmp)
      configureargs="$prereqconfigureargs \
                     --enable-cxx"
      ;;
    mpfr|ppl|isl)
      configureargs="$prereqconfigureargs \
                     --with-gmp=$stagedir"
      ;;
    mpc)
      configureargs="$prereqconfigureargs \
                     --with-gmp=$stagedir \
                     --with-mpfr=$stagedir"
      ;;
    cloog)
      configureargs="--host=$host \
                     --build=$build \
                     --prefix=/ \
                     --disable-shared \
                     --enable-static \
                     --with-gmp-prefix=$stagedir \
                     --with-bits=gmp \
                     --with-isl-prefix=$stagedir"
      ;;
    expat|libiconv)
      configureargs="$prereqconfigureargs"
      ;;
    binutils)
      configureargs="--host=$host \
                     --build=$build \
                     --target=$target \
                     --with-sysroot=$stagedir/$shortname \
                     --prefix=$stagedir/$shortname \
                     --enable-64-bit-bfd \
                     --disable-multilib \
                     --disable-nls \
                     --disable-werror \
                     $gnu_win32_options \
                     $binutilstooldir \
                     $packageversion"
      ;;
    mingw-w64-headers)
      configureargs="--host=$target \
                     --build=$build \
                     --target=$target \
                     --prefix=/$target \
                     --enable-sdk=all \
                     --enable-secure-api"
      ;;
    mingw-w64-crt)
      case "$target" in
        i686-w64-mingw32)
          mingww64crtoptions="--enable-lib32 --disable-lib64"
          ;;
        x86_64-w64-mingw32)
          mingww64crtoptions="--enable-lib64 --disable-lib32"
      esac
      configureargs="--host=$target \
                     --build=$build \
                     --target=$target \
                     --prefix=/$target \
                     --enable-wildcard \
                     $mingww64crtoptions"
    gcc)
      # PPL for older versions
      case "$version" in
        4.[6-7])
          pploptions="--with-ppl=$stagedir \
                      --disable-ppl-version-check \
                      --with-host-libstdcxx='-lstdc++ -lm -gcc_eh'"
      esac
      # bootstrap options
      case "$suffix" in
        *-booststrap)
          gcclanguages="c,lto,c++"
          ;;
        *)
          gcclanguages="c,lto,c++,objc,obj-c++,fortran,java"
      esac
      # exceptions
      case "$target$suffix" in
        # *-sjlj-* gets no options, as they confuse the gcc build system
        i686-*-dw2-*)
          gccexceptions="--enable-dw2-exceptions \
                         --disable-sjlj-exceptions"
          ;;
        x86_64-*-seh-*)
          gccexceptions="--enable-seh-exceptions \
                         --disable-sjlj-exceptions"
          ;;
      esac
      # libgcc thread backend
      case "$suffix" in
        *-pthreads*)
          gccthreads="--enable-threads=posix"
          ;;
        *-win32threads*)
          gccthreads="--enable-threads=win32"
          ;;
      esac
      configureargs="--host=$host \
                     --build=$build \
                     --target=$target \
                     --with-sysroot=$stagedir/$shortname \
                     --prefix=$stagedir/$shortname \
                     --with-gmp=$stagedir \
                     --with-mpfr=$stagedir \
                     --with-mpc=$stagedir \
                     --with-cloog=$stagedir \
                     --disable-cloog-version-check \
                     --enable-cloog-backend=isl \
                     --with-isl=$stagedir \
                     --disable-isl-version-check \
                     $pploptions \
                     --enable-shared \
                     --enable-static \
                     --enable-plugins \
                     --disable-multilib \
                     --enable-languages=$gcclanguages \
                     --enable-libgomp \
                     --disable-libstdcxx-pch \
                     $gccexceptions \
                     $gccthreads \
                     --enable-fully-dynamic-string \
                     --enable-libstdcxx-time \
                     --disable-nls \
                     --disable-werror \
                     --enable-checking=release \
                     --with-gnu-as \
                     --with-gnu-ld \
                     $gnu_win32_options \
                     $packageversion \
                     LDFLAGS=-static"
  
  # configure
  eval $srcdir/configure $configureargs > "$logdir/configure$suffix.log" 2>&1 \
     || { printf "Failure configuring $project$suffix. Check $logdir/configure$suffix.log for details.\n"; exit 1; }
)

build_package()
(
  name="$1"
  version="$2"

  url=$(geturl $name $version)
  patches=$(getpatches $name $version)
  
  
  
  
)