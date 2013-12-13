#! /usr/bin/env sh

# build prerequisites check
check_executables()
(
  all_programs_found=true
  for program in "$@"
  do
    command -v "$program" > /dev/null 2>&1 || { not_found="$not_found\n$program"; all_programs_found=false; }
    printf ">>> Command $program found.\n"
  done
  if ! [ $all_programs_found ]
  then
    printf >&2 "Programs not found: $not_found.\n"
    exit 1
  fi
)

# source release downloads
fetch_source_release()
(
  url="$1"
  name="$2"
  ext="tar.$3"
  file="$name.$ext"
  
  cd "$_CROSS_SOURCE_DIR"

  if [ -f "$file" ]
  then 
    printf ">>> $file already downloaded.\n"
  else
    printf ">>> Downloading $file from $url/$file.\n"
    curl -# -L -o "$file" "$url/$file" || { printf "Failure downloading from $url/$file.\n"; exit 1; }
  fi
  if [ -d "$name" ]
  then
    printf ">>> $file already extracted.\n"
  else
    printf ">>> Extracting $file.\n"
    tar -xf "$file"
  fi

  cd "$_CROSS_SOURCE_DIR/$name"
  for patchfile in "${@:4}"
  do
    printf ">>> Applying patch $patchfile.\n"
    printf "**** Patching $name in $_CROSS_SOURCE_DIR with $patchfile:\n" >> "$_CROSS_LOG_DIR/patches.log"
    set +e
    patch --reject-file=- --forward -p0 -i "$patchfile" >> "$_CROSS_LOG_DIR/patches.log" 2>&1
    set -e
  done
  
  cd "$_CROSS_DIR"
)

fetch_source_svn()
(
  url="$1"
  subdir="$2"
  checkoutdir="$_CROSS_SOURCE_DIR/$3"
  
  if [ -d "$checkoutdir" ]
  then
    cd "$checkoutdir"
    existingurl=`svn info | grep 'Repository Root' | awk '{print $NF}'`
    printf "$existingurl"
  else
    mkdir -p "$checkoutdir"
    cd "$checkoutdir"
    svn co "$url/$subdir" "$checkoutdir" >> "$_CROSS_LOG_DIR/$3-svn" 2>&1 || { printf "Failure checking out $3."; exit 1; }
  fi
)

fetch_llvm()
(
  version="$1"
  url="llvm.org/releases"
)

# Version control downloads
svn_co()
(
  project="$1"
  url="$2"
)

# primary toolchain build functions

build_gnu_toolchain()
(
  shortname="$1"
  if [ -z "$2" ]
  then
    host="$_CROSS_BUILD"
  else
    host="$2"
  fi

  printf ">> Building GCC prerequisites.\n"
  build_prerequisites "$host"
  prereq_install="$_CROSS_PREREQ_DIR/$host/install"
  
  # Toolchain
  toolchain_build="$_CROSS_BUILD_DIR/$host/$shortname"
  toolchain_install="$toolchain_build/$shortname"
  
  case "$shortname" in
    mingw*)
      mkdir -p "$toolchain_install/mingw/include"
      build_mingw_toolchain "$host" "$shortname" "$toolchain_build" "$toolchain_install" "$prereq_install" "$mingw_w64prefix"
      # cleanup
      rm -rf "$toolchain_install/mingw" ;;
    *)
      printf "Unsupported at the moment: $shortname.\n"; exit 1;
  esac
)

build_prerequisites()
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

  case "$_CROSS_GCC_VERSION" in
    4.5*|4.6*|4.7*)
      pplconfigureargs="--host=$host --build=$_CROSS_BUILD --prefix=$prereq_install \
                        --disable-shared --enable-static \
                        --with-gmp=$prereq_install"
      build_with_autotools "ppl" "$prereq_build" "$_CROSS_VERSION_PPL" "$_CROSS_LOG_DIR/$host" \
                           "$pplconfigureargs" "$_CROSS_MAKE_ARGS" ;;
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
  #gccabioptions="--enable-threads=posix"
  case "$shortname" in
    mingw32)
      printf "> Building cross-compiler for 32-bit Windows.\n"
      target="i686-w64-mingw32"
      gccabioptions="$gccabioptions --enable-sjlj-exceptions --disable-dw2-exceptions" ;;
    mingw32-dw2)
      printf "> Building cross-compiler for 32-bit Windows (dw2).\n"
      target="i686-w64-mingw32"
      gccabioptions="$gccabioptions --enable-dw2-exceptions --disable-sjlj-exceptions" ;;
    mingw64)
      printf "> Building cross-compiler for 64-bit Windows.\n"
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
  build_with_autotools "binutils" "$builddir" "$_CROSS_VERSION_BINUTILS" "$_CROSS_LOG_DIR/$host/$target" \
                       "$binutilsconfigureargs" "$_CROSS_MAKE_ARGS tooldir=$prefix"
#  case "$_CROSS_VERSION_GCC" in
#     4.5*|4.6*|4.7*)
#       printf ">> GCC 4.[5-7]\n"
#       gcchostlibstdcxx="" ;;
#   esac
  gccconfigureargs="--host=$host --build=$_CROSS_BUILD --target=$target \
                    --with-sysroot=$prefix --prefix=$prefix \
                    --with-gmp=$prereq_install --with-mpfr=$prereq_install --with-mpc=$prereq_install \
                    --with-cloog=$prereq_install --enable-cloog-backend=isl --with-isl=$prereq_install \
                    $pploptions \
                    --enable-shared --enable-static --enable-plugins \
                    --disable-multilib --enable-libgomp \
                    $gccabioptions \
                    --enable-languages=c,lto,c++,objc,obj-c++,fortran,java,ada \
                    --enable-fully-dynamic-string --enable-libstdcxx-time \
                    --disable-nls --disable-werror --enable-checking=release \
                    --with-gnu-as --with-gnu-ld \
                    $gnu_win32_options $_CROSS_PACKAGE_VERSION \
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
  
  build_with_autotools "gcc" "$builddir" "$_CROSS_VERSION_GCC" "$_CROSS_LOG_DIR/$host/$target" \
                       "$gccconfigureargs" "$_CROSS_MAKE_ARGS"
)

# build functions
build_with_autotools()
(
  project="$1"
  builddir="$2/$project"
  version="$3"
  logdir="$4/$project"
  configureargs="$5"
  makebuildargs="$6"
  if [ -z "$7" ]
  then
    makeinstallargs="install"
  else
    makeinstallargs="$7"
  fi
  buildstep="$8"

  mkdir -p "$logdir"
  mkdir -p "$builddir" && cd "$builddir"

  if [ -f "$builddir/configure$buildstep.marker" ]
  then
    printf ">>> $project$buildstep already configured.\n"
  else
    printf ">>> Configuring $project$buildstep.\n"
    sh "$_CROSS_SOURCE_DIR/$project-$version/configure" $configureargs > "$logdir/configure.log" 2>&1 \
       || { printf "Failure configuring $project$buildstep. Check $logdir/configure.log for details.\n"; exit 1; }
  fi
  touch "$builddir/configure$buildstep.marker"

  mkdir -p "$builddir" && cd "$builddir"

  if [ -f "$builddir/build$buildstep.marker" ]
  then
    printf ">>> $project$buildstep already built.\n"
  else
    printf ">>> Building $project$buildstep.\n"
    make $makebuildargs > "$logdir/build.log" > "$logdir/build$buildstep.log" 2>&1 \
      || { printf "Failure building $project. Check $logdir/build$buildstep.log for details.\n"; exit 1; }
  fi
  touch "$builddir/build$buildstep.marker"
  
  if [ -f "$builddir/install$buildstep.marker" ]
  then
    printf ">>> $project$buildstep already installed.\n"
  else
    printf ">>> Installing $project$buildstep.\n"
    make ${makeinstallargs} > "$logdir/install.log" > "$logdir/install$buildstep.log" 2>&1 \
      || { printf "Failure installing $project. Check $logdir/install$buildstep.log for details.\n"; exit 1; }
  fi
  touch "$builddir/install$buildstep.marker"
  
  cd "$_CROSS_DIR"
)
