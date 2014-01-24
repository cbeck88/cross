#! /usr/bin/env sh

build_with_autotools()
(
  project="$1"
  builddir="$2/$project"
  version="$3"
  host="$4"
  configureargs="$5"
  makebuildargs="$6"
  if [ -z "$7" ]
  then
    makeinstallargs="install-strip"
  else
    makeinstallargs="$7"
  fi
  buildstep="$8"

  builddir="$builddir-$version$buildstep"
  logdir="$_CROSS_LOG_DIR/$host/$project-$version$buildstep"
  mkdir -p "$logdir"

  packagename="$host-$project-$version$buildstep$_CROSS_COMPRESS_EXT"
  if [ -f "$_CROSS_PACKAGE_DIR/$packagename" ]
  then
    printf "unreachable build_with_autotools().\n"
    exit 0
  fi

  if [ -d "$builddir" ]
  then
    rm -rf "$builddir"/*
  else
    mkdir -p "$builddir"
  fi
  cd "$builddir"

  printf ">> Building $host-$project-$version$buildstep.\n"

  printf ">>> Configuring...\n"
  # eval for quoting magic
  eval sh "$_CROSS_SOURCE_DIR/$project-$version/configure" $configureargs > "$logdir/configure$buildstep.log" 2>&1 \
     || { printf "Failure configuring $project$buildstep. Check $logdir/configure$buildstep.log for details.\n"; exit 1; }

  printf ">>> Building...\n"
  make $makebuildargs > "$logdir/build.log" > "$logdir/build$buildstep.log" 2>&1 \
    || { printf "Failure building $project. Check $logdir/build$buildstep.log for details.\n"; exit 1; }

  printf ">>> Installing...\n"
  rm -rf "$_CROSS_STAGE_INSTALL_DIR"
  eval make $makeinstallargs DESTDIR=$_CROSS_STAGE_INSTALL_DIR > "$logdir/install.log" > "$logdir/install$buildstep.log" 2>&1 \
    || { printf "Failure installing $project. Check $logdir/install$buildstep.log for details.\n"; exit 1; }

  rm -rf "$_CROSS_STAGE_DIR"

  cd "$_CROSS_DIR"
)
