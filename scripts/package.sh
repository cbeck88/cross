#! /usr/bin/env sh

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
  
  case $host in
    *-mingw32)
      compress="7za -l -bd -mx9 a"
      ext=".7z"
      ;;
    *)
      compress="tar -Jhcf"
      ext=".tar.xz"
  esac

  $compress "$_CROSS_PACKAGE_DIR/$packagename$ext" * > "$logdir/package$packagesuffix.log" 2>&1 \
    || { printf "Failure packaging $project$packagesuffix. Check $logdir/install$packagesuffix.log for details.\n"; exit 1; }

  cd "$_CROSS_DIR"
  rm -rf "$_CROSS_STAGE_INSTALL_DIR"
)
