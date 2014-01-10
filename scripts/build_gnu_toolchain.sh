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
      abisuffix="-sjlj"
      target="i686-w64-mingw32" ;;
    *mingw64)
      shortname="mingw64"
      case "$_CROSS_VERSION_GCC" in
        4.6*|4.7*)
          abisuffix="-sjlj" ;;
        4.8*|trunk)
          abisuffix="-seh" ;;
      esac
      target="x86_64-w64-mingw32" ;;
    *mingw32-dw2)
      shortname="mingw32-dw2"
      gccexceptionabi="--enable-dw2-exceptions --disable-sjlj-exceptions"
      abisuffix="-dw2"
      target="i686-w64-mingw32" ;;
    *mingw64-sjlj)
      case "$_CROSS_VERSION_GCC" in
        4.[6-7]*)
          printf ">> Skipping 64-bit gcc-$_CROSS_VERSION_GCC-sjlj build because this is the only one possible.\n"
          exit 0 ;;
      esac
      shortname="mingw64-sjlj"
      gccexceptionabi="--disable-seh-exceptions --enable-sjlj-exceptions"
      abisuffix="-sjlj"
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
        export _CROSS_MULTILIB_ENV="CC='gcc -m32' CXX='g++ -m32' AR=ar"
      fi ;;
    i686-*-linux*)
      if [ "$host" = "x86_64-unknown-linux-gnu" ]
      then
        export _CROSS_MULTILIB_ENV="CC='gcc -m64' CXX='g++ -m64' AR=ar"
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
        build_mingw_toolchain "$host" "$shortname" "$abisuffix" "$toolchain_build" || exit 1

        printf ">> Creating $longname toolchain package.\n"
        rm -f "$_CROSS_PACKAGE_DIR/$toolchainpackage"
        stage_projects "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64 mingw-w64-crt-$_CROSS_VERSION_MINGW_W64 \
                                  mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
        stage_projects "${host}_$target" "binutils-$_CROSS_VERSION_BINUTILS gcc-$_CROSS_VERSION_GCC$abisuffix \
                                          gdb-$_CROSS_VERSION_GDB" "$shortname" || exit 1
        case "$longname" in
          mingw32*|mingw64*)
            stage_projects "$host" "make-$_CROSS_VERSION_MAKE" "$shortname" || exit 1
        esac

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
