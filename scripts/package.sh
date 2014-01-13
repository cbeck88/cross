#! /usr/bin/env sh

package()
(
  host="$1"
  packagename="$2"
  if [ -z "$3" ]
  then
    makeinstallargs="install-strip"
  else
    makeinstallargs="$3"
  fi
  
  logdir="$_CROSS_LOG_DIR/$host/$packagename"

  printf ">>> Packaging $packagename...\n"
  cd "$_CROSS_STAGE_INSTALL_DIR"
  find . -name \*.la -exec rm -f {} \;
  $_CROSS_COMPRESS_TAR "$_CROSS_PACKAGE_DIR/$packagename$_CROSS_COMPRESS_EXT" ./* > "$logdir/package$buildstep.log" 2>&1 \
    || { printf "Failure packaging $project$buildstep. Check $logdir/install$buildstep.log for details.\n"; exit 1; }
)