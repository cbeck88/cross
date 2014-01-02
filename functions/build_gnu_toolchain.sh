#! /usr/bin/env sh

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
