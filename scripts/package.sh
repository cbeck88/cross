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
  
  if [ -f "$_CROSS_PACKAGE_DIR/$packagename$_CROSS_COMPRESS_EXT" ]
  then
    exit 0;
  fi

  printf ">>> Packaging $packagename...\n"
  cd "$_CROSS_STAGE_INSTALL_DIR"
  find . -name \*.la -exec rm -f {} \;
  find . -type d -empty -delete
  $_CROSS_COMPRESS_TAR "$_CROSS_PACKAGE_DIR/$packagename$_CROSS_COMPRESS_EXT" ./* > "$logdir/package$packagesuffix.log" 2>&1 \
    || { printf "Failure packaging $project$packagesuffix. Check $logdir/install$packagesuffix.log for details.\n"; exit 1; }
)