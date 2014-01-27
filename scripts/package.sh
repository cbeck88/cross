#! /usr/bin/env sh

package_compress()
(
  case "$1" in
    i686-w64-mingw32*|x86_64-w64-mingw32*)
      echo "7za -l -bd -mx9 a"
      ;;
    *)
      echo "tar -Jhcf"
  esac
)

package_ext()
(
  case "$1" in
    i686-w64-mingw32*|x86_64-w64-mingw32*)
      echo ".7z"
      ;;
    *)
      echo ".tar.xz"
  esac
)

package_decompress()
(
  case "$1" in
    i686-w64-mingw32*|x86_64-w64-mingw32*)
      echo "7za -y x"
      ;;
    *)
      echo "tar -xf"
  esac
)

package()
(
  host="$1"
  projectwithversion="$2"
  if [ -z "$3" ]
  then
    packagesuffix=
  else
    packagesuffix="$3"
  fi

  packagename="$host-$projectwithversion$packagesuffix"

  logdir="$_CROSS_LOG_DIR/$host/$projectwithversion"
  mkdir -p "$logdir"

  printf ">>> Packaging $packagename...\n"
  cd "$_CROSS_STAGE_INSTALL_DIR"
  find . -name \*.la -exec rm -f {} \;
  find . -type d -empty -delete

  compress=$(package_compress $host)
  ext=$(package_ext $host)

  $compress $_CROSS_PACKAGE_DIR/$packagename$ext * > "$logdir/package$packagesuffix.log" 2>&1 \
    || { printf "Failure packaging $project$packagesuffix. Check $logdir/package$packagesuffix.log for details.\n"; exit 1; }

  cd "$_CROSS_DIR"
  rm -rf "$_CROSS_STAGE_INSTALL_DIR"/*
)
