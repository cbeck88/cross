#! /usr/bin/env sh

build_with_autotools()
(
  project="$1"
  builddir="$2/$project$buildstep"
  version="$3"
  host="$4"
  logdir="$_CROSS_LOG_DIR/prereq-$host/$project"
  configureargs="$5"
  makebuildargs="$6"
  if [ -z "$7" ]
  then
    makeinstallargs="install-strip"
  else
    makeinstallargs="$7"
  fi
  buildstep="$8"
  
  mkdir -p "$logdir"
    
  packagename="$host-$project-$version$buildstep$_CROSS_COMPRESS_EXT"
  if [ -f "$_CROSS_PACKAGE_DIR/$packagename" ]
  then
    printf ">>> Package already found, skipping build.\n"
    exit 0
  fi

  if [ -d "$builddir" ]
  then
    rm -rf "$builddir"/*
  else
    mkdir -p "$builddir"
  fi
  cd "$builddir"
  
  printf ">>> Configuring $project$buildstep.\n"
  # eval for quoting magic
  eval sh "$_CROSS_SOURCE_DIR/$project-$version/configure" $configureargs > "$logdir/configure$buildstep.log" 2>&1 \
     || { printf "Failure configuring $project$buildstep. Check $logdir/configure$buildstep.log for details.\n"; exit 1; }
  
  printf ">>> Building $project$buildstep.\n"
  make $makebuildargs > "$logdir/build.log" > "$logdir/build$buildstep.log" 2>&1 \
    || { printf "Failure building $project. Check $logdir/build$buildstep.log for details.\n"; exit 1; }
  
  printf ">>> Installing $project$buildstep.\n"
  rm -rf "$_CROSS_STAGE_INSTALL_DIR"/*
  make $makeinstallargs DESTDIR="$_CROSS_STAGE_INSTALL_DIR" > "$logdir/install.log" > "$logdir/install$buildstep.log" 2>&1 \
    || { printf "Failure installing $project. Check $logdir/install$buildstep.log for details.\n"; exit 1; }
  
  printf ">>> Packaging $host-$project-$version.\n"
  cd "$_CROSS_STAGE_INSTALL_DIR"
  rm -f lib/*.la
  $_CROSS_COMPRESS_TAR "$_CROSS_PACKAGE_DIR/$packagename" ./*
  
  cd "$_CROSS_DIR"
)
