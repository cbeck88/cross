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
      host="i686-w64-mingw32"
      # abisuffix to prevent mixing C++ eh libgcc linkage failures. Only relevant for GMP/PPL.
      case "$_CROSS_VERSION_GCC" in
        4.[6-7]*)
          prereqabisuffix="$abisuffix" ;; 
      esac ;;
    mingw64*)
      host="x86_64-w64-mingw32"
      # abisuffix to prevent mixing C++ eh libgcc linkage failures. Only relevant for GMP/PPL.
      case "$_CROSS_VERSION_GCC" in
        4.[6-7]*)
          prereqabisuffix="$abisuffix" ;;
      esac ;;
    *)
      printf "Error: unknown longname: $longname.\n"
      exit 1 ;;
  esac
  
  ext=$(package_ext $host)
  toolchainpackage=${longname}_gcc-${_CROSS_VERSION_GCC}_rubenvb$ext
  
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
      abisuffix="-dw2"
      target="i686-w64-mingw32" ;;
    *mingw64-sjlj)
      case "$_CROSS_VERSION_GCC" in
        4.[6-7]*)
          toolchainpackagenosjlj=`echo "$toolchainpackage" | sed 's/-sjlj//'`
          if [ ! -h "$_CROSS_PACKAGE_DIR/$toolchainpackage" ]
          then
            ln -s "$_CROSS_PACKAGE_DIR/$toolchainpackagenosjlj" "$_CROSS_PACKAGE_DIR/$toolchainpackage"
          fi
          printf ">> Skipping 64-bit gcc-$_CROSS_VERSION_GCC-sjlj build because this is the only one possible.\n"
          exit 0 ;;
      esac
      shortname="mingw64-sjlj"
      abisuffix="-sjlj"
      target="x86_64-w64-mingw32" ;;
    *)
      printf "Error: unknown longname: $longname.\n"
      exit 1 ;;
  esac
  
  printf "> Building GCC compiler from $host to $target.\n"
  
  printf ">> Building GCC prerequisites.\n"
  build_gnu_prerequisites "$host" "$prereqabisuffix" || exit 1
  
  # Toolchain
  toolchain_build="$_CROSS_BUILD_DIR/$longname"
  
  case "$shortname" in
    mingw*)
      if [ -f "$_CROSS_PACKAGE_DIR/$toolchainpackage" ]
      then
        printf ">> $longname toolchain package already created.\n"
      else
        build_mingw_toolchain "$host" "$shortname" "$toolchain_build" "$abisuffix" "$prereqabisuffix" || exit 1

        printf ">> Creating $longname toolchain package.\n"
        rm -f "$_CROSS_PACKAGE_DIR/$toolchainpackage"
        stage_projects "$target" "mingw-w64-headers-$_CROSS_VERSION_MINGW_W64 mingw-w64-crt-$_CROSS_VERSION_MINGW_W64" "$shortname" || exit 1
        stage_projects "${host}_$target" "binutils-$_CROSS_VERSION_BINUTILS gcc-$_CROSS_VERSION_GCC$abisuffix \
                                          mingw-w64-winpthreads-$_CROSS_VERSION_MINGW_W64 gdb-$_CROSS_VERSION_GDB" "$shortname" || exit 1
                                          
        case "$longname" in
          mingw32*|mingw64*)
            stage_projects "$host" "make-$_CROSS_VERSION_MAKE" "$shortname" || exit 1
            cp "$_CROSS_DIR/envsetup/${shortname}env.cmd" "$_CROSS_STAGE_DIR/$shortname/" || exit 1
        esac

        printf ">>> Compressing full toolchain directory.\n"
        cd "$_CROSS_STAGE_DIR"
        compress=$(package_compress $host)
        $compress "$_CROSS_PACKAGE_DIR/$toolchainpackage" *
        rm -rf "$_CROSS_STAGE_DIR"/*
      fi
      ;;
    *)
      printf "Unsupported at the moment: $shortname.\n"; exit 1;
  esac
  cd "$_CROSS_DIR"
)
