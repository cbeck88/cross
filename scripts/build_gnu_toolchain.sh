#! /usr/bin/env sh

build_gnu_toolchain()
(
  longname="$1"

  case "$longname" in
    linux32*)
      host="i686-unknown-linux-gnu" ;;
    linux64*)
      host="x86_64-unknown-linux-gnu" ;;
    cygwin32*)
      host="i686-pc-cygwin" ;;
    cygwin64*)
      host="x86_64-pc-cygwin" ;;
    mingw32*)
      host="i686-w64-mingw32" ;;
    mingw64*)
      host="x86_64-w64-mingw32" ;;
    *)
      printf "Error: unknown longname: $longname.\n"
      exit 1 ;;
  esac

  case "$longname" in
    *mingw32)
      shortname="mingw32"
      target="i686-w64-mingw32" ;;
    *mingw64)
      shortname="mingw64"
      target="x86_64-w64-mingw32" ;;
    *mingw32-dw2)
      shortname="mingw32-dw2"
      gccexceptionabi="--enable-dw2-exceptions --disable-sjlj-exceptions"
      target="i686-w64-mingw32" ;;
    *mingw64-sjlj)
      shortname="mingw64-sjlj"
      gccexceptionabi="--disable-seh-exceptions --enable-sjlj-exceptions"
      target="x86_64-w64-mingw32" ;;
    *)
      printf "Error: unknown longname: $longname.\n"
      exit 1 ;;
  esac
  
  printf "> Building GCC compiler from $host to $target.\n"
  
  # linux multilib hackery
  case "$_CROSS_BUILD" in
    x86_64-*-linux*)
      if [ "$host" = "i686-unknown-linux-gnu" ]
      then
        export _CROSS_MULTILIB_ENV="CC='gcc -m32' CXX='g++ -m32'"
      fi ;;
    i686-*-linux*)
      if [ "$host" = "x86_64-unknown-linux-gnu" ]
      then
        export _CROSS_MULTILIB_ENV="CC='gcc -m64' CXX='g++ -m64'"
      fi ;;
  esac
  
  printf ">> Building GCC prerequisites.\n"
  build_gnu_prerequisites "$host" || exit 1
  
  # Toolchain
  toolchain_build="$_CROSS_BUILD_DIR/$longname"
  
  case "$shortname" in
    mingw*)
      toolchainpackage=${longname}_gcc-${_CROSS_VERSION_GCC}_rubenvb$_CROSS_COMPRESS_EXT
      if [ -f "$_CROSS_PACKAGE_DIR/$toolchainpackage" ]
      then
        printf ">> $longname toolchain package already created.\n"
      else
        build_mingw_toolchain "$host" "$shortname" "$toolchain_build" || exit 1

        printf ">> Creating $longname toolchain package.\n"
        rm -f "$_CROSS_PACKAGE_DIR/$toolchainpackage"
        stage_project "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64" || exit 1
        stage_project "${host}_$target" "binutils-$_CROSS_VERSION_BINUTILS" || exit 1
        stage_project "$target" "mingw-w64-crt-$_CROSS_VERSION_MINGW_W64" || exit 1
        stage_project "$target" "mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64" || exit 1
        stage_project "${host}_$target" "gcc-$_CROSS_VERSION_GCC" || exit 1

        printf ">>> Compressing full toolchain directory.\n"
        cd "$_CROSS_STAGE_DIR"
        $_CROSS_COMPRESS_TAR "$_CROSS_PACKAGE_DIR/$toolchainpackage" ./*
        rm -rf "$_CROSS_STAGE_DIR"
      fi
      ;;
    *)
      printf "Unsupported at the moment: $shortname.\n"; exit 1;
  esac
  cd "$_CROSS_DIR"
)
